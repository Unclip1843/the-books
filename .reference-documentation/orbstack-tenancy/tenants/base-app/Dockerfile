# syntax=docker/dockerfile:1.7
FROM node:22-alpine
WORKDIR /app

# Install build dependencies for native modules
RUN apk add --no-cache python3 make g++

RUN addgroup -S app && adduser -S app -G app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev --prefer-offline

COPY app.js app.js

# Clean up build dependencies to reduce image size
RUN apk del python3 make g++

# Create data directory for SQLite and files
RUN mkdir -p /app/data && chown -R app:app /app
USER app
EXPOSE 8080
HEALTHCHECK --interval=2s --timeout=1s --retries=15 CMD wget -qO- http://127.0.0.1:8080/health || exit 1
CMD ["node","app.js"]
