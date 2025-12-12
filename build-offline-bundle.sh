#This script to run on the internet machine (pulls images, saves to tar)

#!/usr/bin/env bash
set -euo pipefail

OUTDIR=offline_bundle
mkdir -p "$OUTDIR"

# Versions - adjust if you want specific versions
RABBIT_TAG="4.1-management"        # official RabbitMQ 4.1 management image
GRAFANA_TAG="grafana/grafana:latest"  # example grafana tag — pick the version you require
PROMETHEUS_TAG="prom/prometheus:v3.8.0" # example, pick appropriate version
RABBIT_EXPORTER_TAG="kbudde/rabbitmq-exporter:1.34.2" # popular exporter (adjust if you have a preferred one)

# Pull images
echo "Pulling images..."
docker pull "rabbitmq:${RABBIT_TAG}" || docker pull "rabbitmq:${RABBIT_TAG}"  # try both forms
docker pull "${GRAFANA_TAG}"
docker pull "${PROMETHEUS_TAG}"
docker pull "${RABBIT_EXPORTER_TAG}"

# Save images to a single tar
OUT_TAR="$OUTDIR/rabbitmq_grafana_prometheus_images.tar"
echo "Saving images to $OUT_TAR (this may take a while)..."
docker image save \
  "rabbitmq:${RABBIT_TAG}" \
  "${GRAFANA_TAG}" \
  "${PROMETHEUS_TAG}" \
  "${RABBIT_EXPORTER_TAG}" \
  -o "$OUT_TAR"

# Copy compose and configs
cp docker-compose.yml "$OUTDIR/"
cp prometheus.yml "$OUTDIR/"

# Optional: add scripts and a README
cat > "$OUTDIR/README.txt" <<EOF
Contents:
 - rabbitmq_grafana_prometheus_images.tar  (docker images)
 - docker-compose.yml
 - prometheus.yml

Transfer this directory to the air-gapped VM and run install-offline.sh there.
EOF

echo "Bundle created in $OUTDIR. Transfer it to the offline VM (USB, internal scp, etc)."
