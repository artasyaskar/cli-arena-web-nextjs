// File: src/app/api/auth/login/route.ts

import { NextRequest, NextResponse } from 'next/server';
import { Redis } from '@upstash/redis';
import { Ratelimit } from '@upstash/ratelimit';
import { prisma } from '@/lib/prisma';

// ✅ Create Upstash Redis instance (requires env vars)
const redis = Redis.fromEnv(); // Reads UPSTASH_REDIS_REST_URL & UPSTASH_REDIS_REST_TOKEN

// ✅ Setup rate limiter: 5 requests per minute
const ratelimit = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(5, '1 m'),
  analytics: true,
});

// ✅ Helper to extract IP address from request headers
function getClientIp(req: NextRequest): string {
  return req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() || '127.0.0.1';
}

export async function POST(request: NextRequest) {
  const ip = getClientIp(request);

  const { success } = await ratelimit.limit(ip);
  if (!success) {
    const email = request.headers.get('X-User-Email');
    if (email) {
      const user = await prisma.user.findUnique({ where: { email } });
      if (user) {
        await prisma.log.create({
          data: {
            message: 'Rate limit exceeded',
            userId: user.id,
          },
        });
      }
    }

    return NextResponse.json({ error: 'Too many requests' }, { status: 429 });
  }

  try {
    const { email } = await request.json();

    const user = await prisma.user.findUnique({ where: { email } });

    if (!user) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      );
    }

    // ⚠ In real applications, verify password hash with bcrypt
    // Example:
    // const isValid = await bcrypt.compare(password, user.hashedPassword);

    await prisma.auditLog.create({
      data: {
        userId: user.id,
        action: 'login',
        ipAddress: ip,
        userAgent: request.headers.get('user-agent') ?? 'unknown',
      },
    });

    return NextResponse.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
      },
    });
  } catch (error) {
    console.error('❌ Login error:', error);
    return NextResponse.json({ error: 'Login failed' }, { status: 500 });
  }
}
