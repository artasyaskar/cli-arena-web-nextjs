import { expect, test, vi } from 'vitest';
import { POST as login } from '@/app/api/auth/login/route';
import { POST as logout } from '@/app/api/auth/logout/route';
import { POST as refresh } from '@/app/api/auth/refresh/route';
import { NextRequest } from 'next/server';
import { prisma } from '@/lib/prisma';
import * as jwt from 'jsonwebtoken';

process.env.JWT_SECRET = 'secret';
process.env.REFRESH_SECRET = 'refresh-secret';

vi.mock('@/lib/prisma', () => ({
  prisma: {
    user: {
      findUnique: vi.fn(),
    },
    auditLog: {
      create: vi.fn(),
    },
  },
}));

vi.mock('ratelimiter', () => {
  const Ratelimiter = vi.fn(() => {
    return {
      limit: vi.fn(() => ({ success: true })),
    };
  });
  return { Ratelimiter };
});

beforeEach(() => {
  vi.clearAllMocks();
});

vi.mock('ioredis', () => {
  const Redis = vi.fn(() => ({
    get: vi.fn().mockResolvedValue(null),
    set: vi.fn().mockResolvedValue('OK'),
  }));
  return { Redis };
});

test('should create audit log on login', async () => {
  const user = { id: '1', email: 'test@example.com' };
  (prisma.user.findUnique as any).mockResolvedValue(user);

  const request = new NextRequest('http://localhost/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email: 'test@example.com', password: 'password' }),
    headers: { 'user-agent': 'test-agent' },
  });
  Object.defineProperty(request, 'ip', {
    get: () => '127.0.0.1',
  });

  await login(request);

  expect(prisma.auditLog.create).toHaveBeenCalledWith({
    data: {
      userId: user.id,
      action: 'login',
      ipAddress: '127.0.0.1',
      userAgent: 'test-agent',
    },
  });
});

test('should create audit log on logout', async () => {
    const token = jwt.sign({ userId: '1' }, 'secret');
    const request = new NextRequest('http://localhost/api/auth/logout', {
      method: 'POST',
      headers: { 'user-agent': 'test-agent', 'authorization': `Bearer ${token}` },
    });
    Object.defineProperty(request, 'ip', {
      get: () => '127.0.0.1',
    });

    await logout(request);

    expect(prisma.auditLog.create).toHaveBeenCalledWith({
      data: {
        userId: '1',
        action: 'logout',
        ipAddress: '127.0.0.1',
        userAgent: 'test-agent',
      },
    });
  });

test('should create audit log on token refresh', async () => {
    const refreshToken = jwt.sign({ userId: '1' }, 'refresh-secret');
    const request = new NextRequest('http://localhost/api/auth/refresh', {
      method: 'POST',
      body: JSON.stringify({ refreshToken }),
      headers: { 'user-agent': 'test-agent' },
    });
    Object.defineProperty(request, 'ip', {
      get: () => '127.0.0.1',
    });

    await refresh(request);

    expect(prisma.auditLog.create).toHaveBeenCalledWith({
      data: {
        userId: '1',
        action: 'refresh_token',
        ipAddress: '127.0.0.1',
        userAgent: 'test-agent',
      },
    });
  });
