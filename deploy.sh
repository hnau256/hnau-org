#!/bin/bash

set -e

echo "=== Deploying hnau-org ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# External build directory for upchain-app
UPCHAIN_BUILD_DIR="$SCRIPT_DIR/build/upchain-app"
UPCHAIN_REPO="https://github.com/hnau256/upchain-app.git"

echo -e "${YELLOW}Step 1: Pulling latest changes from hnau-org repository...${NC}"
git pull origin main || git pull origin master || echo "No remote changes or not a git repo"

echo -e "${YELLOW}Step 2: Preparing upchain-app build directory...${NC}"
mkdir -p build

if [ -d "$UPCHAIN_BUILD_DIR/.git" ]; then
    echo -e "${YELLOW}  → Repository exists, updating...${NC}"
    cd "$UPCHAIN_BUILD_DIR"
    git pull origin master || git pull origin main
    cd "$SCRIPT_DIR"
else
    echo -e "${YELLOW}  → Repository not found, cloning...${NC}"
    rm -rf "$UPCHAIN_BUILD_DIR"
    git clone "$UPCHAIN_REPO" "$UPCHAIN_BUILD_DIR"
fi

echo -e "${YELLOW}Step 3: Building upchain-app...${NC}"
cd "$UPCHAIN_BUILD_DIR"
./gradlew :server:installDist --no-daemon
cd "$SCRIPT_DIR"

echo -e "${YELLOW}Step 4: Copying built application to Docker context...${NC}"
rm -rf upchain/dist
mkdir -p upchain/dist
cp -r "$UPCHAIN_BUILD_DIR/server/build/install/server/"* upchain/dist/

echo -e "${YELLOW}Step 5: Creating necessary directories...${NC}"
mkdir -p data/upchain
mkdir -p nginx/certbot-data
mkdir -p nginx/certbot-www

echo -e "${YELLOW}Step 6: Building and starting containers...${NC}"
docker-compose down 2>/dev/null || true
docker-compose up --build -d

echo -e "${YELLOW}Step 7: Waiting for services to start...${NC}"
sleep 10

echo -e "${YELLOW}Step 8: Checking service status...${NC}"
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Services are running${NC}"
    docker-compose ps
else
    echo -e "${RED}✗ Some services failed to start${NC}"
    docker-compose ps
    exit 1
fi

echo ""
echo -e "${GREEN}=== Deployment completed! ===${NC}"
echo ""
echo "SSL certificate will be obtained automatically on first run."
echo ""
echo "To view logs: docker-compose logs -f"
echo "To update and redeploy: ./deploy.sh"