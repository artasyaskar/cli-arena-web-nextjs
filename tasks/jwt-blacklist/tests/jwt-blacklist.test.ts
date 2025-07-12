import { expect, test, vi } from 'vitest';
import { authMiddleware } from '@/middleware/auth';
import { POST as logout } from '@/app/api/auth/logout/route';
import { NextRequest } from 'next/server';
import * as jwt from 'jsonwebtoken';

const SECRET_KEY = 'your-secret-key';
process.env.JWT_SECRET = SECRET_KEY;

vi.mock('ioredis', () => {
  const store: Record<string, string> = {};
  const Redis = vi.fn(() => ({
    get: vi.fn(async (key: string) => store[key] || null),
    set: vi.fn(async (key: string, value: string) => {
      store[key] = value;
      return 'OK';
    }),
  }));
  return { Redis };
});

test('should blacklist a JWT on logout', async () => {
  const token = jwt.sign({ userId: '1' }, SECRET_KEY, { expiresIn: '1h' });
  const request = new NextRequest('http://localhost/api/auth/logout', {
    method: 'POST',
    headers: { authorization: `Bearer ${token}` },
  });

  const response = await logout(request);
  expect(response.status).toBe(200);

  const authRequest = new NextRequest('http://localhost/api/protected', {
    headers: { authorization: `Bearer ${token}` },
  });
  const authResponse = await authMiddleware(authRequest);
  expect(authResponse.status).toBe(401);
});

test('should allow access with a valid, non-blacklisted JWT', async () => {
  const token = jwt.sign({ userId: '2' }, SECRET_KEY, { expiresIn: '1h' });
  const authRequest = new NextRequest('http://localhost/api/protected', {
    headers: { authorization: `Bearer ${token}` },
  });

  const authResponse = await authMiddleware(authRequest);
  expect(authResponse.status).toBe(200);
});
