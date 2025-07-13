import { expect, test, vi } from 'vitest';
import { POST } from '@/app/api/auth/login/route';
import { NextRequest } from 'next/server';
import { prisma } from '@/lib/prisma';

vi.mock('@/lib/prisma', () => ({
  prisma: {
    user: {
      findUnique: vi.fn(),
    },
    log: {
      create: vi.fn(),
    },
    auditLog: {
      create: vi.fn(),
    },
  },
}));

vi.mock('ioredis', () => {
  const Redis = vi.fn(() => ({
    get: vi.fn().mockResolvedValue(null),
    set: vi.fn().mockResolvedValue('OK'),
  }));
  return { Redis };
});

beforeEach(() => {
  vi.clearAllMocks();
});

vi.mock('ratelimiter', () => {
  const Ratelimiter = vi.fn().mockImplementation(() => {
    let remaining = 5;
    return {
      limit: vi.fn(async () => {
        remaining -= 1;
        return {
          success: remaining >= 0,
          total: 5,
          remaining: Math.max(0, remaining),
          reset: new Date(Date.now() + 60000),
        };
      }),
    };
  });
  return { Ratelimiter };
});

test('should return 429 after exceeding rate limit', async () => {
  const user = { id: '1', email: 'test@example.com' };
  (prisma.user.findUnique as any).mockResolvedValue(user);

  const request = new NextRequest('http://localhost/api/auth/login', {
    method: 'POST',
    headers: { 'X-User-Email': 'test@example.com' },
    body: JSON.stringify({ email: 'test@example.com', password: 'password' }),
  });
  Object.defineProperty(request, 'ip', {
    get: () => '127.0.0.1',
  });

  for (let i = 0; i < 5; i++) {
    const response = await POST(request);
    expect(response.status).toBe(200);
  }

  const response = await POST(request);
  expect(response.status).toBe(429);
  expect(prisma.log.create).toHaveBeenCalledWith({
    data: {
      message: 'Rate limit exceeded',
      userId: user.id,
    },
  });
});
