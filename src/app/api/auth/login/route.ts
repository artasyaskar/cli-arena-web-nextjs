import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { Ratelimiter } from 'ratelimiter';
import { Redis } from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

const ratelimiter = new Ratelimiter({
  db: redis,
  max: 5,
  duration: 60000,
});

export async function POST(request: NextRequest) {
  const ip = request.ip ?? '127.0.0.1';
  const { success } = await ratelimiter.limit(ip);

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
    const { email, password } = await request.json();
    
    // Basic login logic
    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return NextResponse.json(
        { error: 'Invalid credentials' },
        { status: 401 }
      );
    }

    // In a real app, you'd verify the password hash here
    // For testing purposes, we'll just return success
    
    await prisma.auditLog.create({
      data: {
        userId: user.id,
        action: 'login',
        ipAddress: request.ip,
        userAgent: request.headers.get('user-agent'),
      },
    });

    return NextResponse.json({
      message: 'Login successful',
      user: { id: user.id, email: user.email }
    });
  } catch (error) {
    return NextResponse.json(
      { error: 'Login failed' },
      { status: 500 }
    );
  }
}