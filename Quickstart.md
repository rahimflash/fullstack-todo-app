# Todo List Application - Docker Deployment Documentation

### Overview

This documentation provides a complete containerization solution for the Todo List application **without unnecessary changes to the existing application code**. The solution works around hardcoded values and configurations in the original code.

### Key Challenges Addressed

1. **Hardcoded MongoDB Connection**: Backend uses `mongodb://127.0.0.1:27017`
2. **Hardcoded API URLs in frontend hooks**: Frontend uses `https://fullstack-todolist-upnv.onrender.com` to make calls to backend. Changed this to `http://localhost:3000` for my use case
3. **No Health Endpoints**: Application doesn't have health check endpoints
4. **No Environment Variables**: Application doesn't read from environment variables

### Solution Architecture

```
┌─────────────────┐
│   Browser       │
│  (Port 80)      │
└────────┬────────┘
         │
┌────────▼────────┐
│  Nginx Frontend │ ◄── Serves React build
│  Container      │     Proxies to backend
└────────┬────────┘
         │
┌────────▼────────┐
│  Node Backend   │ ◄── Runs on port 3000
│  Container      │     Connects to MongoDB
└────────┬────────┘
         │
┌────────▼────────┐
│  MongoDB        │ ◄── Accessible as "127.0.0.1"
│  Container      │     inside backend container
└─────────────────┘
```

## Deployment Instructions

### 1. File Structure

Add these Docker files to your existing project:

```
fullstack-todo-list/
├── Frontend/
│   ├── [existing frontend files]
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .dockerignore
├── Backend/
│   ├── [existing backend files]
│   ├── Dockerfile
│   └── .dockerignore
├── scripts/
│   ├── advanced-test.sh
│   ├── backup-mongodb.sh
│   ├── restore-mongodb.sh
│   ├── test-containers.sh
│   └── monitor-containers.sh
├── docker-compose.yml
├── Quickstart.md
├── Makefile
└── README.md
```

### 2. Quick Deployment

```bash
# Build and start all containers
docker compose up -d --build

# Check if everything is running
docker compose ps

# View logs
docker compose logs -f

# Run tests
chmod +x test-containers.sh
./test-containers.sh
```

### 3. Access the Application

- **Frontend**: http://localhost
- **Backend API**: http://localhost:3000
- **MongoDB**: mongodb://localhost:27017 (from host machine)

## How It Works

### MongoDB Connection Magic

**Host Networking**:
```yaml
mongodb:
  network_mode: "host"  # MongoDB binds to host's 127.0.0.1
backend:
  network_mode: "host"  # Backend can access host's 127.0.0.1
```

### Frontend API Proxy

The nginx configuration proxies API requests to the backend:

```nginx
location /api/ {
    proxy_pass http://backend:3000/api/;
}
```

This means:
- If your React app calls `/api/todos` → proxied to `backend:3000/api/todos`
- If your React app calls `http://localhost:3000/api/gettodos` → direct call

## Troubleshooting Guide

### Issue: MongoDB Connection Failed

**Symptoms**: Backend logs show "MongoDB connection error"

**Solutions**:

1. **Check MongoDB is running**:
   ```bash
   docker compose ps mongodb
   docker compose logs mongodb
   ```

2. **Test connection from backend container**:
   ```bash
   docker exec -it todo-backend sh
   # Inside container:
   ping mongodb
   nc -zv mongodb 27017
   ```

3. **Try alternative docker compose.yml** with host networking

### Issue: Frontend Can't Reach Backend

**Symptoms**: API calls fail in browser

**Check**:

1. **Backend is accessible**:
   ```bash
   curl http://localhost:3000/
   curl http://localhost:3000/api/gettodos
   ```

2. **Nginx proxy is working**:
   ```bash
   curl http://localhost/api/gettodos
   ```

3. **Check browser network tab** for actual URLs being called

### Issue: Containers Won't Start

**Solutions**:

1. **Check ports are free**:
   ```bash
   # Linux/Mac
   lsof -i :80
   lsof -i :3000
   lsof -i :27017
   
   # Windows
   netstat -ano | findstr :80
   netstat -ano | findstr :3000
   netstat -ano | findstr :27017
   ```

2. **Check Docker daemon**:
   ```bash
   docker version
   docker compose version
   ```

## Development Workflow

### Running in Development Mode

For development with hot reloading:

```bash
# Start MongoDB and backend in containers, frontend on host
docker compose up -d mongodb
docker compose up -d backend

# Run frontend locally
cd frontend
npm install
npm run dev
```


### Viewing Logs

```bash
# All containers
docker compose logs -f

# Specific container
docker compose logs -f backend

# Last 100 lines
docker compose logs --tail=100 backend
```

### Restarting Services

```bash
# Restart a specific service
docker compose restart backend

# Rebuild and restart
docker compose up -d --build backend
```

## Maintenance

### Backup MongoDB Data

```bash
# Create backup
docker exec todo-mongodb mongodump --out /backup
docker cp todo-mongodb:/backup ./mongodb-backup

# Restore backup
docker cp ./mongodb-backup todo-mongodb:/restore
docker exec todo-mongodb mongorestore /restore
```

### Clean Up

```bash
# Stop containers
docker compose down

# Remove containers and volumes (WARNING: Deletes data)
docker compose down -v

# Clean up unused Docker resources
docker system prune -a
```

## Performance Considerations

1. **Image Sizes**:
   - Frontend: ~50MB (nginx:alpine + static files)
   - Backend: ~180MB (node:18-alpine + dependencies)
   - MongoDB: ~900MB (official image)

2. **Resource Usage**:
   - Frontend: ~20MB RAM
   - Backend: ~100MB RAM
   - MongoDB: ~200MB RAM (varies with data)

3. **Startup Time**: ~30 seconds for all services

## Security Notes

### Current Setup is for Development

- MongoDB runs without authentication
- All services in isolated Docker network
- Ports are exposed to host for development

### Production Recommendations

When ready for production:

1. **We need to enable MongoDB authentication**:
   ```yaml
   environment:
     MONGO_INITDB_ROOT_USERNAME: admin
     MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
   ```

2. **We need to use environment variables**:
   - Database connection strings
   - API URLs
   - Secrets and tokens

3. **Add SSL/TLS**:
   - Use Let's Encrypt for HTTPS
   - Secure MongoDB connections

4. **Restrict exposed ports**:
   - Only expose nginx (port 80/443)
   - Keep backend and MongoDB internal


## Quick Commands Reference

```bash
# Start everything
make up

# Stop everything
make down

# View logs
make logs

# Run tests
make test

# Clean up
make clean

# Development mode
make dev
```