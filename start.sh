#!/bin/bash
DockerComposeRepo="https://raw.githubusercontent.com/LanOps/teamspeak-docker-compose/master/docker-compose.yml"
# Download and install Docker
curl -fsSL https://get.docker.com -o get-docker.sh | sh get-docker.sh
# Download docker compose file
curl -fsSL $DockerComposeRepo -o compose.yaml
# Add User to Docker group
sudo usermod -aG docker $USER
# Start dockercompose
docker compose up -d
