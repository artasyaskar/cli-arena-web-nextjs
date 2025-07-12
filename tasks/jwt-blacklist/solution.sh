#!/bin/bash

# Install dependencies
npm install ioredis jsonwebtoken @types/jsonwebtoken

# Create auth middleware
mkdir -p src/middleware
cat > src/middleware/auth.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import { Redis } from 'ioredis';
import * as jwt from 'jsonwebtoken';

const redis = new Redis(process.env.REDIS_URL!);

export async function authMiddleware(request: NextRequest) {
  const token = request.headers.get('authorization')?.split(' ')[1];

  if (!token) {
    return new NextResponse('Unauthorized', { status: 401 });
  }

  const isBlacklisted = await redis.get(\`blacklist:\${token}\`);
  if (isBlacklisted) {
    return new NextResponse('Unauthorized', { status: 401 });
  }

  try {
    jwt.verify(token, process.env.JWT_SECRET!);
    return NextResponse.next();
  } catch (error) {
    return new NextResponse('Unauthorized', { status: 401 });
  }
}
EOL

# Create logout route
mkdir -p src/app/api/auth/logout
cat > src/app/api/auth/logout/route.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import { Redis } from 'ioredis';
import * as jwt from 'jsonwebtoken';

const redis = new Redis(process.env.REDIS_URL!);

export async function POST(request: NextRequest) {
  const token = request.headers.get('authorization')?.split(' ')[1];

  if (token) {
    const decoded = jwt.decode(token) as { exp?: number };
    if (decoded?.exp) {
      const expiry = decoded.exp * 1000 - Date.now();
      await redis.set(\`blacklist:\${token}\`, 'true', 'PX', expiry);
    }
  }

  return NextResponse.json({ message: 'Logged out successfully' });
}
EOL
