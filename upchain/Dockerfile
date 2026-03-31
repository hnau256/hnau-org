FROM gradle:8-jdk17 AS builder

WORKDIR /app

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone upchain-app repository
RUN git clone https://github.com/hnau256/upchain-app.git .

# Build the application
RUN ./gradlew :server:installDist --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copy built application from builder
COPY --from=builder /app/server/build/install/server/ .

# Create data directory
RUN mkdir -p /data

# Expose port (not needed for internal communication but good for debugging)
EXPOSE 8080

# Run the application with data directory argument
ENTRYPOINT ["./bin/server"]
CMD ["-d", "/data"]