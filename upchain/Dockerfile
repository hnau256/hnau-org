FROM eclipse-temurin:17-jre

WORKDIR /app

# Copy pre-built application from external build directory
# The build context should be the parent directory containing build/upchain-app
COPY build/upchain-app/server/build/install/server/ .

# Create data directory
RUN mkdir -p /data

# Expose port
EXPOSE 8080

# Run the application with data directory argument
ENTRYPOINT ["./bin/server"]
CMD ["-d", "/data"]