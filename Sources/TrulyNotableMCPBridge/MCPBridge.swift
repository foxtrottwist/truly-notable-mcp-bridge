//
// Sources/TrulyNotableMCPBridge/MCPBridge.swift
//
//  Created by Law Horne on 9/26/25.
//

import Foundation
import Logging
import MCP
import ServiceLifecycle

final class MCPBridge: @unchecked Sendable {
    private let host: String
    private let port: Int
    private let logger: Logger

    private var httpClient: Client?
    private var stdioServer: Server?
    private var httpTransport: HTTPClientTransport?
    private var stdioTransport: StdioTransport?

    init(host: String, port: Int) {
        self.host = host
        self.port = port
        self.logger = Logger(label: "mcp-bridge")
    }

    func start() async throws {
        logger.info("TrulyNotable MCP Bridge v1.0.0")
        logger.info("Starting bridge for TrulyNotable server at \(host):\(port)")

        try await setupHTTPClient()
        try await setupSTDIOServer()

        guard let server = stdioServer, let transport = stdioTransport else {
            throw BridgeError.serverNotInitialized
        }

        // Create MCP service for graceful shutdown
        let mcpService = MCPService(server: server, transport: transport)

        // Create service group with signal handling
        let serviceGroup = ServiceGroup(
            services: [mcpService],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: logger
        )

        logger.info("Bridge ready - waiting for STDIO connections")

        // Run the service group - blocks until shutdown
        try await serviceGroup.run()
    }

    private func setupHTTPClient() async throws {
        let endpoint = URL(string: "http://\(host):\(port)/mcp")!
        httpTransport = HTTPClientTransport(endpoint: endpoint, streaming: false)

        httpClient = Client(
            name: "TrulyNotable Bridge Client",
            version: "1.0.0"
        )

        guard let transport = httpTransport, let client = httpClient else {
            throw BridgeError.initializationFailed
        }

        let result = try await client.connect(transport: transport)
        logger.info("Connected to TrulyNotable server")
        logger.debug("Server capabilities: \(result.capabilities)")
    }

    private func setupSTDIOServer() async throws {
        stdioTransport = StdioTransport()

        stdioServer = Server(
            name: "TrulyNotable Bridge",
            version: "1.0.0",
            capabilities: .init(
                tools: .init(listChanged: true)
            )
        )

        await registerHandlers()
    }

    private func registerHandlers() async {
        guard let server = stdioServer else { return }

        // Forward list_tools to HTTP client
        await server.withMethodHandler(ListTools.self) { [weak self] params in
            await self?.handleListTools(params) ?? ListTools.Result(tools: [])
        }

        // Forward call_tool to HTTP client
        await server.withMethodHandler(CallTool.self) { [weak self] params in
            await self?.handleCallTool(params)
                ?? CallTool.Result(
                    content: [.text("Bridge error")],
                    isError: true
                )
        }
    }

    private func handleListTools(_ params: ListTools.Parameters) async -> ListTools.Result {
        guard let client = httpClient else {
            return ListTools.Result(tools: [])
        }

        do {
            let (tools, _) = try await client.listTools()
            logger.debug("Listed \(tools.count) tools from TrulyNotable")
            return ListTools.Result(tools: tools)
        } catch {
            logger.error("Error listing tools: \(error)")
            return ListTools.Result(tools: [])
        }
    }

    private func handleCallTool(_ params: CallTool.Parameters) async -> CallTool.Result {
        guard let client = httpClient else {
            return CallTool.Result(
                content: [.text("HTTP client not available")],
                isError: true
            )
        }

        do {
            logger.debug("Calling tool: \(params.name)")
            let (content, isError) = try await client.callTool(
                name: params.name,
                arguments: params.arguments
            )
            return CallTool.Result(content: content, isError: isError)
        } catch {
            logger.error("Error calling tool '\(params.name)': \(error)")
            return CallTool.Result(
                content: [.text("Tool call failed: \(error.localizedDescription)")],
                isError: true
            )
        }
    }
}

// MARK: - MCP Service for graceful shutdown

struct MCPService: Service {
    let server: Server
    let transport: Transport

    func run() async throws {
        try await server.start(transport: transport)

        // Wait for graceful shutdown signal
        try await gracefulShutdown()
    }

    func shutdown() async throws {
        await server.stop()
    }
}

enum BridgeError: Error {
    case initializationFailed
    case serverNotInitialized
}
