
FROM node:20-bookworm-slim AS build
WORKDIR /app

# Install deps first for better layer caching
COPY package.json package-lock.json* yarn.lock* ./
RUN if [ -f package-lock.json ]; then \
      npm ci; \
    else \
      yarn install --frozen-lockfile; \
    fi

COPY . .
RUN npm run build

# ---- Runtime stage ----
FROM nginx:stable-alpine AS runtime
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
