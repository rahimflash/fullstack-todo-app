#!/bin/bash

# Real-time Container Monitoring Script

clear
echo "Real-time Container Monitoring (Press Ctrl+C to exit)"
echo "========================================================"

while true; do
    # Clear previous output
    tput cup 3 0
    
    # Show timestamp
    echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Container status
    echo "Container Status:"
    docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" | head -n 4
    echo ""
    
    # Resource usage
    echo "Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | grep -E "todo-|CONTAINER" | head -n 4
    echo ""
    
    # Recent logs (errors only)
    echo "Recent Errors (last 5 minutes):"
    for container in todo-mongodb todo-backend todo-frontend; do
        errors=$(docker logs --since 5m "$container" 2>&1 | grep -i "error" | tail -n 1)
        if [ -n "$errors" ]; then
            echo "  $container: $errors" | cut -c1-80
        fi
    done
    
    sleep 5
done