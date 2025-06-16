#!/bin/bash

# Advanced Container Testing Script with Performance Metrics

# Import basic functions from test-containers.sh
source ./test-containers.sh 2>/dev/null || true

# Performance test function
performance_test() {
    echo ""
    echo "7. Performance Testing..."
    
    # Test API response time
    echo -n "   API Response Time: "
    response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:3000/api/todos)
    if (( $(echo "$response_time < 1.0" | bc -l) )); then
        echo -e "${GREEN}${response_time}s (Good)${NC}"
    else
        echo -e "${YELLOW}${response_time}s (Slow)${NC}"
    fi
    
    # Test Frontend load time
    echo -n "   Frontend Load Time: "
    load_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost)
    if (( $(echo "$load_time < 0.5" | bc -l) )); then
        echo -e "${GREEN}${load_time}s (Good)${NC}"
    else
        echo -e "${YELLOW}${load_time}s (Slow)${NC}"
    fi
}

# Security test function
security_test() {
    echo ""
    echo "8. Security Testing..."
    
    # Check if MongoDB port is properly secured
    echo -n "   MongoDB Authentication: "
    if docker exec todo-mongodb mongosh --eval "db.adminCommand('ping')" 2>&1 | grep -q "Authentication failed"; then
        echo -e "${GREEN}✓ Enabled${NC}"
    else
        echo -e "${YELLOW}⚠ Check authentication${NC}"
    fi
    
    # Check HTTPS redirect (if configured)
    echo -n "   HTTPS Configuration: "
    if curl -s -I http://localhost | grep -q "301\|302"; then
        echo -e "${GREEN}✓ Redirect enabled${NC}"
    else
        echo -e "${YELLOW}⚠ Not configured${NC}"
    fi
}

# Load test function
load_test() {
    echo ""
    echo "9. Basic Load Testing..."
    
    if command -v ab &> /dev/null; then
        echo "   Running 100 requests with concurrency 10..."
        ab -n 100 -c 10 -q http://localhost:3000/api/health 2>&1 | grep -E "Requests per second:|Time per request:" | sed 's/^/   /'
    else
        echo -e "${YELLOW}   Apache Bench (ab) not installed. Skipping load test.${NC}"
    fi
}

# Container resource usage
resource_usage() {
    echo ""
    echo "10. Resource Usage..."
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep -E "todo-|CONTAINER"
}

# Run all tests
echo "Advanced Container Testing"
echo "============================="

# Run basic tests first
./test-containers.sh

# Run advanced tests
performance_test
security_test
load_test
resource_usage

echo ""
echo "============================="
echo "Advanced testing complete!"