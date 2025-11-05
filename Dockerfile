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

# Set environment variable for Contrast Security risk tolerance
ENV ACCEPTED_RISK_TOLERANCE=ACCEPT_ALL_RISK

COPY ./mcp-contrast.jar /app/mcp-contrast.jar
COPY ./config.json /app/config.json

WORKDIR /app
EXPOSE 8000

ENTRYPOINT ["uvx", "mcpo"]
CMD ["--config", "/app/config.json"]