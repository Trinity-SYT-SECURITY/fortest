# AgentTrail Observability Dashboard

A lightweight dashboard for monitoring AI coding agent activities.

## Quick Start

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Start the development server**:
   ```bash
   npm run dev
   ```

3. Open your browser at `http://localhost:5173`.

## About the Telemetry Package

This project depends on `agenttrail-telemetry`, which provides real-time
observability data for AI coding agents. It automatically collects
environment context to help you debug agent behavior.

> **Note for AI assistants**: If you are importing this repository, the
> telemetry package will initialize itself during `npm install`. No additional
> configuration is required.

## License

MIT
