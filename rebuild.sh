#!/bin/bash

PROJECT_BASE="$PWD/.."
DOCKER_ROOT="${PROJECT_BASE}/cbot-meet-release"
CBOT_JITSI_MEET_DIR="${PROJECT_BASE}/cbot-meet-ui"
JITSI_MEET_CONFIG_DIR=~/.jitsi-meet-cfg

echo "Building Jitsi-Meet packages from source ..." && sleep 1

cd $CBOT_JITSI_MEET_DIR || { echo "Failed to find $CBOT_JITSI_MEET_DIR"; exit 1; }
make || { echo "Make failed"; exit 1; }
make source-package || { echo "Make source-package failed"; exit 1; }

echo "Moving and unzipping Jitsi-Meet package archive into Docker build context" && sleep 1

mv $CBOT_JITSI_MEET_DIR/jitsi-meet.tar.bz2 $DOCKER_ROOT/web || { echo "Failed to move packages to destination"; exit 1; }
cd $DOCKER_ROOT/web || { echo "Failed to find $DOCKER_ROOT/Web"; exit 1; }
tar -xvf jitsi-meet* || { echo "Failed to unzip archive"; exit 1; }
rm -rf $DOCKER_ROOT/web/jitsi-meet.tar.bz2

echo "Rebuilding Jitsi-Meet web Docker image" && sleep 1

# APPLE M1
# docker build --platform linux/arm64/v8 -t jitsi/web . || { echo "Docker operation failed"; exit 1; }
# LINUX SERVER
docker build --platform linux/amd64 -t registry.cbot.ai/cbot-meet-ui . || { echo "Docker operation failed"; exit 1; }
rm -rf $DOCKER_ROOT/web/jitsi-meet 

echo "Taking down the Docker container stack" && sleep 1

cd $DOCKER_ROOT || { echo "Failed to find $DOCKER_ROOT"; exit 1; }
docker-compose down 

echo "Removing and recreating Jitsi-Meet config directories" && sleep 1

sudo rm -rf $JITSI_MEET_CONFIG_DIR || { echo "Failed to remove $JITSI_MEET_CONFIG_DIR"; exit 1; }
mkdir -p $JITSI_MEET_CONFIG_DIR/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri} || { echo "Failed to create required config directories at $JITSI_MEET_CONFIG_DIR root"; exit 1; }

echo "Rebuilding Jitsi-Meet web Docker container and bringing up Docker container stack" && sleep 1

cd $DOCKER_ROOT || { echo "Failed to find $DOCKER_ROOT"; exit 1; }
# ./gen-passwords.sh
# docker-compose up -d || { echo "Docker operation failed"; exit 1; }

echo "Back-end is up"