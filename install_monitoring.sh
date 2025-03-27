#!/bin/bash

# Définition des variables
DIR="monitoring"
COMPOSE_FILE="$DIR/docker-compose.yml"
ENV_FILE="$DIR/.env"
PROMETHEUS_CONFIG="$DIR/prometheus.yml"

# Création du dossier principal
mkdir -p "$DIR"

# Création du fichier .env
cat <<EOL > "$ENV_FILE"
# Ports
PROMETHEUS_PORT=9090
NODE_EXPORTER_PORT=9100
CADVISOR_PORT=8080
GRAFANA_PORT=3000

# Credentials Grafana
GRAFANA_USER=admingrafana
GRAFANA_PASSWORD=changeme
EOL

# Création du fichier docker-compose.yml
cat <<EOL > "$COMPOSE_FILE"
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: always
    ports:
      - "\${PROMETHEUS_PORT}:9090"
    volumes:
      - ./Prometheus_data:/prometheus
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: always
    ports:
      - "\${NODE_EXPORTER_PORT}:9100"
    networks:
      - monitoring

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: always
    ports:
      - "\${CADVISOR_PORT}:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: always
    ports:
      - "\${GRAFANA_PORT}:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=\${GRAFANA_USER}
      - GF_SECURITY_ADMIN_PASSWORD=\${GRAFANA_PASSWORD}
    volumes:
      - ./Grafana_data:/var/lib/grafana
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
EOL

# Création du fichier prometheus.yml
cat <<EOL > "$PROMETHEUS_CONFIG"
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
EOL

# Modification des droits sur le dossier 
mkdir Grafana_data
mkdir Prometheus_data
chmod 770 Grafana_data
chmod 770 Prometheus_data


echo "✅ Configuration complète avec restart: always !"
echo "📂 Dossier créé : $DIR"
echo "🚀 Pour démarrer : cd $DIR && docker compose up -d"
