FROM node:18-alpine AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY app/package*.json ./

RUN npm ci && npm cache clean --force

FROM node:18-alpine

RUN apk add --no-cache ffmpeg

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY app/ ./app/
COPY config/ ./config/
COPY public/ ./public/

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

EXPOSE 3000

RUN chmod -R 755 /app && \
    mkdir -p /app/config /app/logs && \
    chmod 777 /app/config /app/logs

VOLUME ["/app/config", "/app/logs"]

USER node

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

CMD ["node", "app/src/server.js"]
