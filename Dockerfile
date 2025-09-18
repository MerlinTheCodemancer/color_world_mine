# Base image: lightweight OpenJDK for running Forge installer and server
FROM eclipse-temurin:17-jre-jammy

# Create a non-root user
RUN useradd -m -d /home/mc mc
WORKDIR /home/mc

# Install unzip and bash
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    ca-certificates \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY start-forge.sh /usr/local/bin/start-forge.sh
RUN chmod +x /usr/local/bin/start-forge.sh

# Expose default minecraft port
EXPOSE 25565

# Use non-root user
USER mc

ENTRYPOINT ["/usr/local/bin/start-forge.sh"]
CMD [""]
