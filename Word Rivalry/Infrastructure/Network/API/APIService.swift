//
//  APIService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//


import Foundation
import CloudKit
import CommonCrypto
import JWTKit
import OSLog

/// Enumeration for handling success HTTP status codes.
enum SuccessHTTPStatusCode: Int {
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInfo = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    
    /// Checks if a given status code is within the range of success codes.
    static func includes(_ code: Int) -> Bool {
        return (200...299).contains(code)
    }
}

/// Enumeration for handling failure HTTP status codes, categorizing them based on common scenarios.
enum FailureHTTPStatusCode: Int, Error {
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case payloadTooLarge = 413
    case uriTooLong = 414
    case unsupportedMediaType = 415
    case rangeNotSatisfiable = 416
    case expectationFailed = 417
    case imATeapot = 418 // Easter egg status code
    
    /// Initialize from any integer by finding a matching value or nil.
    init?(code: Int) {
        self.init(rawValue: code)
    }
}

/// An enumeration defining possible HTTP errors that can occur during network requests.
enum HTTPError: Error {
    case invalidURL                             // URL provided is not valid.
    case network(URLError)                      // Errors related to network issues.
    case decodingError(DecodingError)           // Errors occurring during the decoding of the response.
    case encodingError(EncodingError)           // Errors occurring during the encoding of the request body.
    case badHttpResponse(FailureHTTPStatusCode) // Response received with a non-2xx status code.
    case clientError(Int)
    case serverError(Int)
    case invalidResponse
    case unknown(Error?)                        // An unexpected error occurred.
}

/// Structure containing constants for various network error codes.
struct NetworkErrorCodes {
    static let connectionFailureCodes: Set<Int> = [
        NSURLErrorBackgroundSessionInUseByAnotherProcess, // `-996`
        NSURLErrorTimedOut,                               // `-1001`
        NSURLErrorCannotFindHost,                         // `-1003`
        NSURLErrorCannotConnectToHost,                    // `-1004`
        NSURLErrorNetworkConnectionLost,                  // `-1005`
        NSURLErrorNotConnectedToInternet,                 // `-1009`
        NSURLErrorSecureConnectionFailed                  // `-1200`
    ]
}

enum APIRequestStatus<SuccessType> {
    case success(SuccessType)
    case failure(HTTPError)
}

/// Extension on the `Error` type to check if an error is due to network connection failure.
extension Error {
    /// Determines if the error is a network connection error based on predefined codes.
    func isConnectionError() -> Bool {
        guard let urlError = self as? URLError else { return false }
        return NetworkErrorCodes.connectionFailureCodes.contains(urlError.code.rawValue)
    }
}

/// API Service for handling network requests with advanced configurations and error handling.
struct APIService {
    
    enum Operation: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
        
    private let securityApplicator: RequestSecurityApplicator
    private let urlSession: URLSession
    private let container: CKContainer
    private var database: CKDatabase
    
    private func fetchUserRecordID() async throws -> CKRecord.ID {
        try await container.userRecordID()
    }
    
    static let shared: APIService = .init()
    
    /// Initializes a new instance of the API service with default session configurations.
    /// This setup is designed to balance connectivity, performance, and data usage considerations.
    private init() {
        self.container = CKContainer(identifier: "iCloud.WordRivalryContainer")
        self.database = container.publicCloudDatabase
        self.securityApplicator = .init(
            jwtProvider: .init(),
            hmacGenerator: .init(secretKey: "development")
        )
        let configuration = URLSessionConfiguration.default
        
        /// Configures the session to wait for connectivity before making a request.
        /// This avoids failing requests and instead waits for an adequate connection.
        configuration.waitsForConnectivity = true
        
        /// Allows the network requests to be made over cellular connections.
        /// Set this to `false` to restrict network requests to WiFi/Ethernet connections only.
        configuration.allowsCellularAccess = true
        
        /// Disables network access over expensive interfaces such as certain types of cellular connections.
        /// This can be beneficial for users with limited or costly data plans.
        configuration.allowsExpensiveNetworkAccess = false
        
        /// Disables network access when the device is in Low Data Mode.
        /// This helps reduce data usage when the user has enabled data conservation measures.
        configuration.allowsConstrainedNetworkAccess = false
        
        /// Sets the maximum duration (in seconds) that a request can take before timing out.
        /// This timeout interval applies to the request phase, not the entire task.
        configuration.timeoutIntervalForRequest = 60.0
        
        /// Sets the maximum duration (in seconds) that the app can take to download the requested resource.
        /// If the resource is not downloaded within this timeframe, the task fails.
        configuration.timeoutIntervalForResource = 10.0
        
        urlSession = URLSession(configuration: configuration)
    }
    
    // Unified data request method for GET, POST, PUT, DELETE
    func requestData<T: Decodable, U: Encodable>(
        url: String,
        body: U = EmptyBody(),
        method: Operation,
        expecting type: T.Type
    ) async -> APIRequestStatus<T> {
        guard let url = URL(string: url) else {
            return .failure(.invalidURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Encode body if it is not EmptyBody
            if !(body is EmptyBody) && method != .GET {
                let encoder = JSONEncoder()
                urlRequest.httpBody = try encoder.encode(body)
            }
            
            let userRecordID = try await fetchUserRecordID()
            
            // Apply security
            try await securityApplicator.applySecurity(to: &urlRequest, userID: "3AB603AD-0F03-49F1-B2E4-66A69A564C6A")
            
        } catch let encodingError as EncodingError {
            return .failure(.encodingError(encodingError))
        } catch let urlError as URLError where urlError.isConnectionError() {
            return .failure(.network(urlError))
        } catch {
            return .failure(.unknown(error))
        }
        
        return await sendRequest(urlRequest, expecting: type)
    }
    
    private func sendRequest<T: Decodable>(
        _ request: URLRequest,
        expecting type: T.Type
    ) async -> APIRequestStatus<T> {
        do {
            let (data, response) = try await urlSession.data(for: request)
            return processResponse(response, withData: data, expecting: type)
        } catch let decodingError as DecodingError {
            return .failure(.decodingError(decodingError))
        } catch let urlError as URLError where urlError.isConnectionError() {
            return .failure(.network(urlError))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    /// Process the HTTP response and decode the data if it's valid.
    private func processResponse<T: Decodable>(
        _ response: URLResponse,
        withData data: Data,
        expecting type: T.Type
    ) -> APIRequestStatus<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidResponse)
        }
        
        let statusCode = httpResponse.statusCode
        
        if SuccessHTTPStatusCode.includes(httpResponse.statusCode) {
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                return .success(decodedData)
            } catch {
                return .failure(.decodingError(error as! DecodingError))
            }
        } else if let failureStatus = FailureHTTPStatusCode(code: statusCode) {
            return .failure(.badHttpResponse(failureStatus))
        } else if statusCode >= 400 && statusCode < 500 {
            return .failure(.clientError(statusCode))
        } else if statusCode >= 500 && statusCode < 600 {
            return .failure(.serverError(statusCode))
        } else {
            return .failure(.unknown(nil))
        }
    }
}

/// A simple structure to use as an empty body for HTTP DELETE requests.
struct EmptyBody: Encodable {}
