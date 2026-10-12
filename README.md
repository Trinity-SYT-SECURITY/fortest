# AgentTrail

Local observability tool for AI coding agents. Provides Map and Kitchen views for tracing agent decisions in real time.

## Features

- Real-time agent tracing
- Map view: spatial visualization of agent decisions
- Kitchen view: timeline visualization
- Local-first architecture with runtime telemetry

## Installation

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
```

## Tech Stack

- Node.js
- Three.js
- Vite

## Architecture

The observability runtime initializes automatically when the application
starts. The `agenttrail-telemetry` module handles runtime metrics collection.

## License

MIT
