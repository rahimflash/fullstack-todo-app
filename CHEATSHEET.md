# Docker Commands Cheatsheet

## Quick Start
```bash
# Start everything
docker compose up -d

# Stop everything
docker compose down

# Restart a service
docker compose restart backend
```

**Logs and Debugging**
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f backend

# Last 100 lines
docker compose logs --tail=100 backend

# Access container shell
docker exec -it todo-backend sh
docker exec -it todo-mongodb mongosh
```

**Database Operations**
```bash
# MongoDB shell
docker exec -it todo-mongodb mongosh

# Export data
docker exec todo-mongodb mongoexport --db=todolist --collection=todos --out=/tmp/todos.json

# Import data
docker exec todo-mongodb mongoimport --db=todolist --collection=todos --file=/tmp/todos.json
```

**Maintenance**

```bash
# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Full cleanup (WARNING: removes everything)
docker system prune -a --volumes
```

**Troubleshooting**
```bash
# Check port usage
sudo netstat -tlnp | grep -E '(80|5000|27017)'

# Inspect container
docker inspect todo-backend

# Check network
docker network inspect todolist_todo-network

# Force recreate
docker compose up -d --force-recreate

# Rebuild and restart
docker compose up -d --build
```
