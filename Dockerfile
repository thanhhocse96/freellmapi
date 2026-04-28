# Stage 1: Build
FROM node:20-alpine AS builder

RUN apk add --no-cache python3 make g++

WORKDIR /app

# Copy TẤT CẢ package.json của workspace (quan trọng!)
COPY package*.json ./
COPY shared/package*.json ./shared/
COPY server/package*.json ./server/
COPY client/package*.json ./client/

RUN npm install

COPY . .

RUN npm run build

# Stage 2: Run
FROM node:20-alpine AS runner

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/shared/package*.json ./shared/
COPY --from=builder /app/server/package*.json ./server/
COPY --from=builder /app/client/package*.json ./client/

# Cài lại production deps (bao gồm rebuild better-sqlite3)
RUN npm install --omit=dev

COPY --from=builder /app/server/dist ./server/dist
COPY --from=builder /app/client/dist ./client/dist

EXPOSE 3001

CMD ["node", "server/dist/index.js"]
