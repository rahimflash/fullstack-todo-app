# Use the official Node.js LTS Alpine image for smaller size and better security
FROM node:22-alpine AS base

# Set the working directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy package files first for better layer caching
COPY package*.json ./

# Install dependencies in a separate stage for better caching
FROM base AS deps
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM base AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

RUN apk add --no-cache curl

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application code
COPY . .

# Remove development dependencies and files
RUN rm -rf .git .gitignore README.md Dockerfile* docker-compose* && \
    npm prune --production && \
    npm uninstall nodemon

# Set NODE_ENV to production
ENV NODE_ENV=production

# Expose the port your app runs on
EXPOSE 3000

# Switch to non-root user
USER nodejs

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["npm", "start"]