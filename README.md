# mcpo-docker

An example Docker image for [mcpo](https://github.com/open-webui/mcpo), a tool that exposes MCP (Model Context Protocol) servers as OpenAPI-compatible HTTP endpoints for [OpenWebUI](https://github.com/open-webui/open-webui).

# MCPO + Contrast Security Integration Guide

This guide walks you through setting up a complete integration between mcpo and Contrast Security using the Model Context Protocol (MCP). If you have not already gone through and setup your environment, take a look at [Mac-Development-Setup-Guide-Beginner.md](Mac-Development-Setup-Guide-Beginner.md)

## Overview

By the end of this guide, you'll have:
- An MCP server (mcpo) running with Contrast Security integration

## Prerequisites

- Docker and Docker Compose installed
- Basic familiarity with command line operations
- Contrast Security account and API credentials
## Step 3: Set Up MCP Server with Contrast Security

### 3.1 Create Project Directory
```bash
mkdir mcpo-contrast-integration
cd mcpo-contrast-integration
```

### 3.2 Download MCP Contrast JAR
Download the latest JAR file for mcp-contrast from GitHub releases:

```bash
# Download the JAR file directly from GitHub releases
curl -L -o mcp-contrast.jar https://github.com/Contrast-Security-OSS/mcp-contrast/releases/download/v0.0.14/mcp-contrast-0.0.14.jar
```

**Alternative: Build from Source**
If you prefer to build from source:
```bash
# Clone the mcp-contrast repository
git clone https://github.com/Contrast-Security-OSS/mcp-contrast.git

# Navigate to the repository
cd mcp-contrast

# Build the JAR file using Docker
docker build -t mcp-contrast .

# Copy the JAR file to your project directory
cp target/mcp-contrast-*.jar ../mcp-contrast.jar

# Return to your project directory
cd ..
```


### 3.3 Create Dockerfile
```dockerfile
FROM python:3.11-slim

LABEL org.opencontainers.image.title="mcpo"
LABEL org.opencontainers.image.description="Docker image for mcpo (Model Context Protocol OpenAPI Proxy)"
LABEL org.opencontainers.image.source="https://github.com/alephpiece/mcpo-docker"
LABEL org.opencontainers.image.licenses="MIT"

# install npx and OpenJDK JRE 21
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nodejs \
    npm \
    openjdk-21-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

COPY ./mcp-contrast.jar /app/mcp-contrast.jar
COPY ./config.json /app/config.json

WORKDIR /app
EXPOSE 8000

ENTRYPOINT ["uvx", "mcpo"]
CMD ["--config", "/app/config.json"]
```

### 3.4 Create Docker Compose File
```yaml
services:
  mcpo:
    build: .
    container_name: mcpo
    image: mcpo-docker
    ports:
      - "8000:8000"
    volumes:
      - ./config.json:/app/config.json
      - ./mcp-contrast.jar:/app/mcp-contrast.jar
```

### 3.5 Create MCP Configuration
Create `config.json` with your Contrast Security credentials:

```json
{
    "mcpServers": {
        "sequential-thinking": {
            "command": "npx",
            "args": [
                "-y",
                "@modelcontextprotocol/server-sequential-thinking"
            ]
        },
        "memory": {
            "command": "npx",
            "args": [
                "-y",
                "@modelcontextprotocol/server-memory"
            ]
        },
        "time": {
            "command": "uvx",
            "args": [
                "mcp-server-time",
                "--local-timezone=America/New_York"
            ]
        },
        "contrast-mcp": {
            "command": "/usr/bin/java", 
            "args": ["-jar","/app/mcp-contrast.jar",
            "--CONTRAST_HOST_NAME=https://your-contrast-server.com",
            "--CONTRAST_API_KEY=your-api-key",
            "--CONTRAST_SERVICE_KEY=your-service-key",
            "--CONTRAST_USERNAME=your-username",
            "--CONTRAST_ORG_ID=your-org-id"]
        }
    }
}
```

**⚠️ Important**: Replace the placeholder values with your actual Contrast Security credentials:
- `your-contrast-server.com` - Your Contrast Security server URL
- `your-api-key` - Your Contrast API key
- `your-service-key` - Your Contrast service key  
- `your-username` - Your Contrast username
- `your-org-id` - Your Contrast organization ID

### 3.6 Add Contrast MCP JAR
If you followed step 3.2, you should already have the `mcp-contrast.jar` file in your directory. If not, copy your `mcp-contrast.jar` file to this directory.

### 3.7 Build and Run MCP Server
```bash
# Build the container
docker-compose build

# Start the MCP server
docker-compose up -d

# Verify it's running and connected
docker logs mcpo
```

You should see logs showing successful connections to all MCP servers, including `contrast-mcp`.

**URL**: `http://localhost:8000/contrast-mcp/openapi.json` or `http://mcpo:8000/contrast-mcp/openapi.json` wherever you can access the container that you just spun up.
