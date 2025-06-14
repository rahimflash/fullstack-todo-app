# Using the official Node.js LTS Alpine image

FROM node:22-alpine AS base

# Set the working directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy package files first for better layer caching
COPY package*.json ./

# Install dependencies stage
FROM base AS deps
RUN npm ci --only=production && npm cache clean --force

# Install all dependencies (including dev) for building
FROM base AS deps-dev
RUN npm ci && npm cache clean --force

# Build stage
FROM base AS build
COPY --from=deps-dev /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Production stage with Nginx
FROM nginx:alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create a non-root user for nginx
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S nginx-app -u 1001

# Copy built assets from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create nginx directories and set permissions
RUN mkdir -p /var/cache/nginx /var/log/nginx /tmp/nginx && \
    chown -R nginx-app:nginx-app /var/cache/nginx /var/log/nginx /tmp/nginx /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx /var/log/nginx /tmp/nginx

# Create a custom nginx.conf that doesn't require writing to /run
RUN echo 'pid /tmp/nginx.pid;' > /tmp/nginx_prefix.conf && \
    cat /etc/nginx/nginx.conf >> /tmp/nginx_prefix.conf && \
    mv /tmp/nginx_prefix.conf /etc/nginx/nginx.conf

# Switch to non-root user
USER nginx-app

# Expose port 8080 (non-privileged port)
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start nginx
CMD ["nginx", "-g", "daemon off;"]