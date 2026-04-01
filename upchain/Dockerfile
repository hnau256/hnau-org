FROM eclipse-temurin:17-jre

WORKDIR /app

# Copy pre-built application from dist directory
# The dist directory is populated by deploy.sh before docker build
COPY dist/ .

# Create data directory
RUN mkdir -p /data

# Expose port
EXPOSE 8080

# Run the application with data directory argument
ENTRYPOINT ["./bin/server"]
CMD ["-d", "/data", "-p", "8080"]