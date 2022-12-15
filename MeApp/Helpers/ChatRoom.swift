//
//  ChatRoom.swift
//  MeApp
//
//  Created by Dmitry on 12/9/22.
//

import Foundation
import NIOTLS
import NIO
import NIOSSL
import NIOFoundationCompat
import Combine
import SwiftUI

public class ChatRoom: Identifiable {
    private let ip: String
    private let port: Int
    public var configuration: TLSConfiguration
    public let sslContext: NIOSSLContext
    public private(set) var client: EventLoopFuture<any Channel>
    public let bootstrap: ClientBootstrap
    public let group: MultiThreadedEventLoopGroup
   
    
    private init(configuration: TLSConfiguration,
                 sslContext: NIOSSLContext,
                 client: EventLoopFuture<any Channel>,
                 bootstrap: ClientBootstrap,
                 ip: String,
                 port: Int,
                 group: MultiThreadedEventLoopGroup,
                 compeltion: @escaping ((Data) -> ())
    ) {
        self.configuration = configuration
        self.sslContext = sslContext
        self.client = client
        self.ip = ip
        self.port = port
        self.bootstrap = bootstrap
        self.group = group
    }
    
    static func connect (with ip: String, port: Int, bind: MeModel, completion: @escaping ((Data) -> ())) -> Result<ChatRoom, Error> {
        do {
            var configuration = TLSConfiguration.makeClientConfiguration()
            configuration.certificateVerification = .noHostnameVerification
            let data = try! Data(contentsOf: Bundle.main.url(forResource: "certificate", withExtension: "pem")!)
            let array = data.withUnsafeBytes {
                [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
            }
            configuration.trustRoots = .certificates([try! NIOSSLCertificate(bytes: array, format: .pem)])
            let sslContext = try NIOSSLContext(configuration: configuration)
            let group = MultiThreadedEventLoopGroup.init(numberOfThreads: 2)
            let ip = ip
            let port = port
            
            
            let bootstrap = ClientBootstrap(group: group)
                .channelInitializer { channel in
                    let handler = try! NIOSSLClientHandler(context: sslContext, serverHostname: "\(ip):\(port)")
                    return channel.pipeline.addHandler(handler).flatMap { v in
                        return channel.pipeline.addHandler(ByteToMessageHandler(LineDelimiterCodec())).flatMap { v in
                            let chatHandler = ChatHandler()
                            chatHandler.onReceive = completion
                            chatHandler.onActive = {
                                DispatchQueue.main.async {
                                    bind.isConnected = true
                                }
                            }
                            chatHandler.onClose = {
                                DispatchQueue.main.async {
                                    bind.isConnected = false
                                }
                            }
                            return channel.pipeline.addHandler(chatHandler)
                        }
                    }
                    
                }
            let client = bootstrap.connect(host: ip, port: port)
            return .success(
                .init(
                    configuration: configuration,
                    sslContext: sslContext,
                    client: client,
                    bootstrap: bootstrap,
                    ip: ip,
                    port: port,
                    group: group,
                    compeltion: completion
                )
            )
        } catch let error {
            return .failure(error)
        }
    }
    static func getIpAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                } else if (name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3") {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(1), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    func sendMessage(msg: Message) {
        self.client.whenSuccess { channel in
            var data = try? JSONEncoder().encode(msg)
            var dd = "\(data?.count ?? 0)|".data(using: .utf8)!
            dd.append(data ?? Data())
            let container = channel.allocator.buffer(data: dd )
            try? channel.writeAndFlush(container)
            return
        }
    }
    func reconnect() {
        self.client.whenSuccess { channel in
            if !channel.isActive {
                self.client = self.bootstrap.connect(host: self.ip, port: self.port)
            }
        }
    }
}
