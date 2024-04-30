//
//  quic.swift
//  Word Rivalry
//
//  Created by benoit barbier on 2024-04-30.
//

import Foundation
import Network

protocol NetworkServiceProtocol {
    func connect()
    func disconnect()
    func send(data: Data)
    func receive(completion: @escaping (Data?, Error?) -> Void)
    var onConnectionReady: (() -> Void)? { get set }
    var onConnectionFailed: ((Error) -> Void)? { get set }
    var onReceivedData: ((Data) -> Void)? { get set }
}

class QUICService: NetworkServiceProtocol {
    private var connection: NWConnection?
    private var networkMonitor: NWPathMonitor?
    private let queue = DispatchQueue.global()

    var onConnectionReady: (() -> Void)?
    var onConnectionFailed: ((Error) -> Void)?
    var onReceivedData: ((Data) -> Void)?

    var waitsForConnectivity: Bool = false
    var usesConstrainedNetworks: Bool = false

    init(
        host: String,
        port: NWEndpoint.Port,
        direction: NWProtocolQUIC.Options.Direction = .unidirectional,
        usesConstrainedNetworks: Bool = false,
        waitsForConnectivity: Bool = false
    ) {
        self.waitsForConnectivity = waitsForConnectivity
        self.usesConstrainedNetworks = usesConstrainedNetworks

        let quicOptions = NWProtocolQUIC.Options()
        quicOptions.alpn = ["h3"]  // HTTP/3
        quicOptions.direction = direction
        
        let parameters = NWParameters(quic: quicOptions)
        parameters.prohibitedInterfaceTypes = usesConstrainedNetworks ? [] : [.cellular, .other]
        parameters.requiredInterfaceType = .wifi

        connection = NWConnection(host: NWEndpoint.Host(host), port: port, using: parameters)
        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            if path.isExpensive {
                if self?.usesConstrainedNetworks == false {
                    print("Connection is expensive, waiting for a less costly option.")
                    return
                }
            }

            if path.status == .satisfied {
                self?.connect()
            } else {
                self?.disconnect()
            }
        }
        networkMonitor?.start(queue: queue)
    }

    func connect() {
           connection?.stateUpdateHandler = { [weak self] state in
               switch state {
               case .ready:
                   self?.onConnectionReady?()
               case .failed(let error):
                   self?.onConnectionFailed?(error)
               default:
                   break
               }
           }
           connection?.start(queue: queue)
       }

       func disconnect() {
           connection?.cancel()
           connection = nil
       }

       func send(data: Data) {
           connection?.send(content: data, completion: .contentProcessed({ error in
               if let error = error {
                   self.onConnectionFailed?(error)
               }
           }))
       }

       func receive(completion: @escaping (Data?, Error?) -> Void) {
           connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
               completion(data, error)
               if isComplete {
                   self.disconnect()
               }
           }
       }
}
