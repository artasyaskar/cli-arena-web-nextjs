#!/bin/bash

# 1. Install dependencies
npm install ioredis

# 2. Create the rate-limiting middleware
mkdir -p src/middleware
cat << 'EOF' > src/middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import Redis from 'ioredis';

const redis = new Redis();

export async function middleware(req: NextRequest) {
  const ip = req.ip ?? '127.0.0.1';
  const key = `rate-limit:${ip}`;

  const current = await redis.get(key);
  const count = current ? parseInt(current, 10) : 0;

  if (count >= 10) {
    return new NextResponse('Too Many Requests', { status: 429 });
  }

  await redis.multi().incr(key).expire(key, 60).exec();

  return NextResponse.next();
}

export const config = {
  matcher: '/api/:path*',
};
EOF
