# This script to run on the offline VM (loads images, runs compose), it assumes Docker and docker-compose are already installed on the target VM. 

#!/usr/bin/env bash
set -euo pipefail

BUNDLE_DIR="${1:-.}"   # directory containing the bundle
TARFILE="$BUNDLE_DIR/rabbitmq_grafana_prometheus_images.tar"

if [ ! -f "$TARFILE" ]; then
  echo "Missing $TARFILE"
  exit 1
fi

echo "Loading docker images..."
docker load -i "$TARFILE"

echo "Starting services with docker-compose..."
docker compose up -d   # or `docker-compose up -d` on older installs

echo "All done. Services starting. Check 'docker ps' and the ports:"
echo " - RabbitMQ management: http://<VM_IP>:15672 (admin/admin)"
echo " - Prometheus: http://<VM_IP>:9090"
echo " - Grafana: http://<VM_IP>:3000 (admin/admin)"
