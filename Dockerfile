# Use Bun base image
FROM oven/bun:1.2.19-slim as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package.json and workspace configuration
COPY package.json bun.lock ./
COPY turbo.json ./

# Copy all package.json files for workspace dependencies
COPY apps/ apps/
COPY packages/ packages/

# Install dependencies
RUN bun install --frozen-lockfile

# Build the application
RUN bun run build

# Production stage
FROM oven/bun:1.2.19-slim as production

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy built application
COPY --from=base /app ./

# Expose port
EXPOSE 3001

# Start the dashboard application
CMD ["bun", "run", "start:dashboard"]