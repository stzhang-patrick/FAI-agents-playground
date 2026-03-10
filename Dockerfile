# Dockerfile for livekit-agents-playground

# ---- 1. Builder Stage ----
FROM node:22-alpine AS builder

# Install pnpm v9 (compatible with lockfileVersion 9.0)
RUN npm install -g pnpm@9

# Set working directory
WORKDIR /app

# Copy dependency descriptor files
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies)
# --no-frozen-lockfile needed because package.json may have updates not in lockfile
RUN pnpm install --no-frozen-lockfile

# Copy all source code
COPY . .

# Build Next.js app
RUN pnpm build

# ---- 2. Runner Stage ----
FROM node:22-alpine AS runner

# Install pnpm v9 (compatible with lockfileVersion 9.0)
RUN npm install -g pnpm@9

# Set working directory
WORKDIR /app

# Copy build artifacts from builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml

# Copy .env.local for runtime environment variables
COPY --from=builder /app/.env.local ./.env.local

# Install production dependencies only to reduce image size
RUN pnpm install --only=production

# Expose port (Next.js default is 3000)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

# Set environment variable
ENV NODE_ENV=production

# Start command
CMD ["pnpm", "start"]