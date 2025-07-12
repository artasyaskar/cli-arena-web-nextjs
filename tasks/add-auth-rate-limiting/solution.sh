#!/bin/bash

# Install dependencies
npm install ioredis ratelimiter

# Create rate-limiting middleware
cat > src/middleware/rateLimit.ts << EOL
import { Ratelimiter } from 'ratelimiter';
import { Redis } from 'ioredis';
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

const redis = new Redis(process.env.REDIS_URL!);
const ratelimiter = new Ratelimiter({
  db: redis,
  max: 5, // max requests per minute
  duration: 60000, // 1 minute
});

export async function rateLimitMiddleware(request: NextRequest) {
  const id = request.ip ?? '127.0.0.1';
  const limit = await ratelimiter.get({ id });

  if (!limit.remaining) {
    const userEmail = request.headers.get('X-User-Email');
    if (userEmail) {
      const user = await prisma.user.findUnique({ where: { email: userEmail } });
      if (user) {
        await prisma.log.create({
          data: {
            message: 'Rate limit exceeded',
            userId: user.id,
          },
        });
      }
    }
    return new NextResponse('Too Many Requests', { status: 429 });
  }

  return NextResponse.next();
}
EOL

# Create a placeholder for the login route if it doesn't exist
mkdir -p src/app/api/auth/login
cat > src/app/api/auth/login/route.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import { rateLimitMiddleware } from '@/middleware/rateLimit';

export async function POST(request: NextRequest) {
  const rateLimitResponse = await rateLimitMiddleware(request);
  if (rateLimitResponse.status === 429) {
    return rateLimitResponse;
  }
  // Your login logic here
  return NextResponse.json({ message: 'Login successful' });
}
EOL
