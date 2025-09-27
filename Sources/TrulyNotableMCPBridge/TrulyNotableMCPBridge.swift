//
// Sources/TrulyNotableMCPBridge/TrulyNotableMCPBridge.swift
//
//  Created by Law Horne on 9/26/25.
//

import ArgumentParser
import Foundation
import Logging

@main
struct TrulyNotableMCPBridge: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mcp-bridge",
        abstract: "MCP bridge for TrulyNotable HTTP server",
        version: "1.0.0"
    )

    @Option(name: .shortAndLong, help: "TrulyNotable server port")
    var port: Int = 3001

    @Option(name: .shortAndLong, help: "TrulyNotable server host")
    var host: String = "127.0.0.1"

    @Flag(help: "Enable verbose logging")
    var verbose: Bool = false

    func run() async throws {
        // Configure logging once
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = verbose ? .debug : .error
            return handler
        }

        let logger = Logger(label: "mcp-bridge.main")
        logger.info("TrulyNotable MCP Bridge starting...")

        do {
            let bridge = MCPBridge(host: host, port: port)
            try await bridge.start()
        } catch {
            logger.error("Bridge startup failed: \(error)")
            throw error
        }
    }
}
