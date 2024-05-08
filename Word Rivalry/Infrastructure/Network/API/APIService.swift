//
//  APIService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import Foundation

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
    case badResponse                            // Unkown response
    case unknown(Error)                         // An unexpected error occurred.
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
    private let urlSession: URLSession
    
    /// Initializes a new instance of the API service with default session configurations.
    /// This setup is designed to balance connectivity, performance, and data usage considerations.
    init() {
        let sessionConfiguration = URLSessionConfiguration.default
        
        /// Configures the session to wait for connectivity before making a request.
        /// This avoids failing requests and instead waits for an adequate connection.
        sessionConfiguration.waitsForConnectivity = true
        
        /// Allows the network requests to be made over cellular connections.
        /// Set this to `false` to restrict network requests to WiFi/Ethernet connections only.
        sessionConfiguration.allowsCellularAccess = true
        
        /// Disables network access over expensive interfaces such as certain types of cellular connections.
        /// This can be beneficial for users with limited or costly data plans.
        sessionConfiguration.allowsExpensiveNetworkAccess = false
        
        /// Disables network access when the device is in Low Data Mode.
        /// This helps reduce data usage when the user has enabled data conservation measures.
        sessionConfiguration.allowsConstrainedNetworkAccess = false
        
        /// Sets the maximum duration (in seconds) that a request can take before timing out.
        /// This timeout interval applies to the request phase, not the entire task.
        sessionConfiguration.timeoutIntervalForRequest = 60.0
        
        /// Sets the maximum duration (in seconds) that the app can take to download the requested resource.
        /// If the resource is not downloaded within this timeframe, the task fails.
        sessionConfiguration.timeoutIntervalForResource = 10.0
        
        /// Creates a URLSession with the above configurations.
        /// This session handles all data transfer tasks configured by the sessionConfiguration.
        urlSession = URLSession(configuration: sessionConfiguration)
    }
    
    
    /// Fetches data from the specified URL and decodes it to the specified Decodable type.
    /// This function initiates a network request to retrieve JSON data, which it then attempts to decode into the specified Swift type.
    ///
    /// - Parameters:
    ///   - urlString: The string representing the URL from which to fetch data.
    ///   - type: The type into which the fetched data should be decoded.
    /// - Returns: An `APIRequestStatus` containing either the decoded data or an error detailing what went wrong.
    func fetchData<T: Decodable>(
        from urlString: String,
        expecting type: T.Type
    ) async -> APIRequestStatus<T> {
        
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.assumesHTTP3Capable = true
        urlRequest.httpMethod = "GET"
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            return processFetchResponse(response, withData: data, expecting: type)
        } catch let decodingError as DecodingError {
            return .failure(.decodingError(decodingError))
        } catch let urlError as URLError where urlError.isConnectionError() {
            return .failure(.network(urlError))
        } catch {
            return .failure(.unknown(error))
        }
    }
    
    /// Process the HTTP response and decode the data if it's valid.
    private func processFetchResponse<T: Decodable>(_ response: URLResponse, withData data: Data, expecting type: T.Type) -> APIRequestStatus<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.badResponse)
        }
        
        if SuccessHTTPStatusCode.includes(httpResponse.statusCode) {
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                return .success(decodedData)
            } catch {
                return .failure(.decodingError(error as! DecodingError))
            }
        } else if let failureCode = FailureHTTPStatusCode(code: httpResponse.statusCode) {
            return .failure(.badHttpResponse(failureCode))
        } else {
            return .failure(.badHttpResponse(.badRequest)) // Default or fallback failure
        }
    }
    
    /// Method for sending a POST request with an encodable body.
    /// This method wraps the `sendData` function to specifically handle POST requests, simplifying its use.
    ///
    /// - Parameters:
    ///   - url: The URL string to which to POST data.
    ///   - body: The object to send, which must conform to `Encodable`.
    /// - Returns: An `APIRequestStatus` reflecting the success or failure of the operation.
    func post<T: Encodable>(url: String, body: T) async -> APIRequestStatus<SuccessHTTPStatusCode> {
        return await sendData(to: url, body: body, method: "POST")
    }
    
    /// Method for sending a PUT request with an encodable body.
    /// This method leverages the `sendData` function for PUT operations, providing a straightforward way to update resources on the server.
    ///
    /// - Parameters:
    ///   - url: The URL string to which to PUT data.
    ///   - body: The object to send, which must conform to `Encodable`.
    /// - Returns: An `APIRequestStatus` reflecting the success or failure of the operation.
    func put<T: Encodable>(url: String, body: T) async -> APIRequestStatus<SuccessHTTPStatusCode> {
        return await sendData(to: url, body: body, method: "PUT")
    }
    
    /// Method for sending a DELETE request.
    /// This function creates a DELETE request with no body content, typically used to remove resources from the server.
    ///
    /// - Parameters:
    ///   - url: The URL string from which to delete a resource.
    /// - Returns: An `APIRequestStatus` reflecting the success or failure of the operation.
    func delete(url: String) async -> APIRequestStatus<SuccessHTTPStatusCode> {
        return await sendData(to: url, body: EmptyBody(), method: "DELETE")
    }
    
    /// Sends data to the specified URL using the specified HTTP method.
    /// This method serializes the provided Encodable object into JSON and sends it to the given URL using the specified HTTP method.
    ///
    /// - Parameters:
    ///   - urlString: The string representing the URL to which to send data.
    ///   - body: The object to encode and send, conforming to `Encodable`.
    ///   - method: The HTTP method to use ("POST", "PUT", "DELETE", etc.).
    /// - Returns: An `APIRequestStatus` reflecting the success or failure of the operation.
    private func sendData<T: Encodable>(
        to urlString: String,
        body: T,
        method: String
    ) async -> APIRequestStatus<SuccessHTTPStatusCode> {
        
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.assumesHTTP3Capable = true
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(body)
            let (_, response) = try await urlSession.data(for: urlRequest)
            return processHTTPResponse(response)
        } catch let encodingError as EncodingError {
            return .failure(.encodingError(encodingError))
        } catch let urlError as URLError where urlError.isConnectionError() {
            return .failure(.network(urlError))
        } catch {
            return .failure(.unknown(error))
        }
    }

    /// Processes the HTTP response, checking for success or failure status codes.
    private func processHTTPResponse(_ response: URLResponse) -> APIRequestStatus<SuccessHTTPStatusCode> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.badResponse)
        }
        
        if let successStatusCode = SuccessHTTPStatusCode(rawValue: httpResponse.statusCode) {
            return .success(successStatusCode)
        } else if let failureCode = FailureHTTPStatusCode(code: httpResponse.statusCode) {
            return .failure(.badHttpResponse(failureCode))
        } else {
            return .failure(.badHttpResponse(.badRequest)) // Default or fallback failure
        }
    }
}

/// A simple structure to use as an empty body for HTTP DELETE requests.
struct EmptyBody: Encodable {}
