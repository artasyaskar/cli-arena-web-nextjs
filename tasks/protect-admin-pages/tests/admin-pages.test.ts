import { expect, test, vi } from 'vitest';
import { rbacMiddleware } from '@/middleware/rbac';
import { NextRequest } from 'next/server';
import { prisma } from '@/lib/prisma';
import * as jwt from 'jsonwebtoken';

process.env.JWT_SECRET = 'secret';

vi.mock('@/lib/prisma', () => ({
  prisma: {
    user: {
      findUnique: vi.fn(),
    },
  },
}));

test('should allow access to admin routes for admin users', async () => {
  const adminUser = { id: '1', role: 'ADMIN' };
  (prisma.user.findUnique as any).mockResolvedValue(adminUser);
  const token = jwt.sign({ userId: '1' }, 'secret');

  const request = new NextRequest('http://localhost/admin/dashboard', {
    headers: { authorization: `Bearer ${token}` },
  });

  const response = await rbacMiddleware(request);
  expect(response.status).toBe(200);
});

test('should deny access to admin routes for non-admin users', async () => {
  const user = { id: '2', role: 'USER' };
  (prisma.user.findUnique as any).mockResolvedValue(user);
  const token = jwt.sign({ userId: '2' }, 'secret');

  const request = new NextRequest('http://localhost/admin/dashboard', {
    headers: { authorization: `Bearer ${token}` },
  });

  const response = await rbacMiddleware(request);
  expect(response.status).toBe(403);
});
