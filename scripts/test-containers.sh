#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Todo App Container Testing"
echo "============================"

# Check if containers are running
echo "1. Checking containers..."
containers=("todo-mongodb" "todo-backend" "todo-frontend")
all_running=true

for container in "${containers[@]}"; do
    echo -n "   $container: "
    if docker ps --format '{{.Names}}' | grep -q "^$container$"; then
        echo -e "${GREEN}Running${NC}"
    else
        echo -e "${RED}Not running${NC}"
        all_running=false
    fi
done

if [ "$all_running" = false ]; then
    echo -e "${YELLOW}Some containers are not running. Run 'docker compose up -d' first.${NC}"
    exit 1
fi

# Test MongoDB
echo ""
echo "2. Testing MongoDB..."
echo -n "   Connection: "
if docker exec todo-mongodb mongosh --eval "db.adminCommand('ping')" --quiet > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}Failed${NC}"
fi

# Test Backend
echo ""
echo "3. Testing Backend..."
echo -n "   Root endpoint: "
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/)
if [ "$response" = "200" ]; then
    echo -e "${GREEN}OK (Status: $response)${NC}"
else
    echo -e "${RED}Failed (Status: $response)${NC}"
fi

echo -n "   API endpoint: "
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/gettodos)
if [ "$response" = "200" ] || [ "$response" = "201" ]; then
    echo -e "${GREEN}OK (Status: $response)${NC}"
else
    echo -e "${YELLOW}Status: $response${NC}"
fi

# Test Frontend
echo ""
echo "4. Testing Frontend..."
echo -n "   Nginx: "
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$response" = "200" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}Failed (Status: $response)${NC}"
fi

# Test API Proxy
echo -n "   API Proxy: "
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/gettodos)
if [ "$response" = "200" ] || [ "$response" = "201" ]; then
    echo -e "${GREEN}OK (Status: $response)${NC}"
else
    echo -e "${YELLOW}Status: $response (check if frontend uses /api prefix)${NC}"
fi

echo ""
echo "============================"
echo "Testing complete!"
echo ""
echo "Access points:"
echo "  Frontend: http://localhost"
echo "  Backend: http://localhost:3000"
echo "  MongoDB: mongodb://localhost:27017"