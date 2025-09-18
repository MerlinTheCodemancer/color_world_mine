#!/bin/bash
set -euo pipefail

# Default memory settings if not provided
MAX_MEMORY=${MAX_MEMORY:-1G}
INIT_MEMORY=${INIT_MEMORY:-1G}
EULA_VALUE=${EULA:-FALSE}
FORGE_DIR=/opt/forge
DATA_DIR=/data

log() { echo "[$(date -Is)] $*"; }

# If /data doesn't exist, create it and set ownership
if [ ! -d "${DATA_DIR}" ]; then
  mkdir -p "${DATA_DIR}"
fi

# If no server jar inside /data, try to find an installer in mounted /opt/forge
if [ -z "$(ls -A ${DATA_DIR} 2>/dev/null)" ] || [ ! -f "${DATA_DIR}/forge-server.jar" -a ! -f "${DATA_DIR}/server.jar" ]; then
  log "No server files in ${DATA_DIR}. Looking for installer in ${FORGE_DIR}..."
  if [ -d "${FORGE_DIR}" ] && ls "${FORGE_DIR}"/*installer*.jar >/dev/null 2>&1; then
    INSTALLER_JAR=$(ls "${FORGE_DIR}"/*installer*.jar | head -n1)
    log "Found installer: ${INSTALLER_JAR}. Running installer..."
    # Run installer to install server into /data
    java -jar "${INSTALLER_JAR}" --installServer "${DATA_DIR}"
    log "Installer completed."
  else
    log "No installer found in ${FORGE_DIR}. If you intended to provide the server jar, place it in ${DATA_DIR}."
  fi
fi

# Ensure EULA
if [ "${EULA_VALUE^^}" = "TRUE" ]; then
  echo "eula=true" > "${DATA_DIR}/eula.txt"
  log "Wrote eula.txt = true"
else
  log "EULA not accepted (EULA=${EULA_VALUE}). Server will not start until EULA is accepted."
  exit 1
fi

# Find the forge server jar (look for *forge*.jar or server.jar)
cd "${DATA_DIR}"
SERVER_JAR=""
if ls *forge*.jar >/dev/null 2>&1; then
  SERVER_JAR=$(ls *forge*.jar | head -n1)
elif [ -f server.jar ]; then
  SERVER_JAR=server.jar
fi

if [ -z "${SERVER_JAR}" ]; then
  log "Could not find a Forge server jar in ${DATA_DIR}. Contents:"
  ls -la "${DATA_DIR}"
  exit 2
fi

log "Starting Forge server using ${SERVER_JAR} with -Xms${INIT_MEMORY} -Xmx${MAX_MEMORY}"
exec java -Xms${INIT_MEMORY} -Xmx${MAX_MEMORY} -jar "${SERVER_JAR}" nogui
