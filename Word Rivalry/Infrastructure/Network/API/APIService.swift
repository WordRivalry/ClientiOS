//
//  APIService.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import Foundation

/// An enumeration defining possible HTTP errors that can occur during network requests.
enum HTTPError: Error {
    case invalidURL        // URL provided is not valid.
    case network(Error)    // Errors related to network issues.
    case decodingError     // Errors occurring during the decoding of the response.
    case encodingError     // Errors occurring during the encoding of the request body.
    case badHttpResponse   // Response received with a non-2xx status code.
    case unknown(Error)    // An unexpected error occurred.
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
    ///
    /// - Parameters:
    ///   - urlString: The URL string to fetch data from.
    ///   - type: The type of data to decode into.
    /// - Returns: The decoded object of type `T`.
    /// - Throws: `HTTPError` for any errors encountered during the fetch or decode process.
    func fetchData<T: Decodable>(from urlString: String, expecting type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.assumesHTTP3Capable = true
        urlRequest.httpMethod = "GET"
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw HTTPError.badHttpResponse
            }
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch _ as DecodingError {
            throw HTTPError.decodingError
        } catch {
            if let urlError = error as? URLError, urlError.isConnectionError() {
                throw HTTPError.network(urlError)
            } else {
                throw HTTPError.unknown(error)
            }
        }
    }
    
    /// Sends data to the specified URL using the specified HTTP method.
    ///
    /// - Parameters:
    ///   - urlString: The URL string to send data to.
    ///   - body: The body of the request, which must conform to `Encodable`.
    ///   - method: The HTTP method to use (e.g., "POST", "PUT", "DELETE").
    /// - Throws: `HTTPError` for any encoding or network-related errors.
    func sendData<T: Encodable>(to urlString: String, body: T, method: String) async throws {
        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.assumesHTTP3Capable = true
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(body)
            let (_, response) = try await urlSession.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw HTTPError.badHttpResponse
            }
        } catch _ as EncodingError {
            throw HTTPError.encodingError
        } catch {
            if let urlError = error as? URLError, urlError.isConnectionError() {
                throw HTTPError.network(urlError)
            } else {
                throw HTTPError.unknown(error)
            }
        }
    }
    
    /// Convenience method for sending a POST request with an encodable body.
    func post<T: Encodable>(url: String, body: T) async throws {
        try await sendData(to: url, body: body, method: "POST")
    }
    
    /// Convenience method for sending a PUT request with an encodable body.
    func put<T: Encodable>(url: String, body: T) async throws {
        try await sendData(to: url, body: body, method: "PUT")
    }
    
    /// Convenience method for sending a DELETE request.
    func delete(url: String) async throws {
        try await sendData(to: url, body: EmptyBody(), method: "DELETE")
    }
}

/// A simple structure to use as an empty body for HTTP DELETE requests.
struct EmptyBody: Encodable {}
