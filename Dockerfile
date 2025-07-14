# Dockerfile for the cli-arena-web-nextjs project

# Use Node 20 LTS (compatible with canvas, Prisma, tsx)
FROM node:20-alpine

# Install native dependencies for canvas, tsx, and Prisma
RUN apk add --no-cache \
  build-base \
  cairo-dev \
  jpeg-dev \
  pango-dev \
  giflib-dev \
  pixman-dev \
  python3 \
  pkgconfig \
  openssl \
  openssl-dev

# Set working directory
WORKDIR /usr/src/app

# Copy only package files to leverage Docker layer caching
COPY package*.json ./

# Install all dependencies
RUN npm install --legacy-peer-deps

# Copy Prisma schema early so `prisma generate` doesn't fail
COPY prisma ./prisma

# Generate Prisma client
RUN npx prisma generate

# Copy rest of the application code
COPY . .

# Build the app
RUN npm run build

# Set NODE_ENV to production
ENV NODE_ENV=production

# Expose the app port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
