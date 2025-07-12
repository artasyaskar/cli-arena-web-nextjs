import { expect, test, vi, afterEach } from 'vitest';
import { GET } from '@/app/api/logs/stream/route';
import { log, logEmitter } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { prisma } from '@/lib/prisma';

vi.mock('@/lib/prisma', () => ({
  prisma: {
    log: {
      create: vi.fn(),
    },
  },
}));

afterEach(() => {
  vi.clearAllMocks();
  logEmitter.removeAllListeners();
});

test('should stream log events to a client', async () => {
  const request = new NextRequest('http://localhost/api/logs/stream');
  const response = await GET(request);
  const reader = response.body?.getReader();

  const logEntry = { id: '1', message: 'test log', userId: '1' };
  (prisma.log.create as any).mockResolvedValue(logEntry);

  let receivedData = '';
  const readPromise = reader?.read().then(async ({ value }) => {
    receivedData = new TextDecoder().decode(value);
  });

  await log('test log', '1');
  await readPromise;

  expect(receivedData).toBe(`data: ${JSON.stringify(logEntry)}\n\n`);
});
