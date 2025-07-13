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

beforeEach(() => {
  vi.clearAllMocks();
  logEmitter.removeAllListeners();
});

vi.mock('@/lib/logger', () => {
  const EventEmitter = require('events');
  const logEmitter = new EventEmitter();
  return {
    log: vi.fn(),
    logEmitter,
  };
});

test('should stream log events to a client', async () => {
  const request = new NextRequest('http://localhost/api/logs/stream?userId=1');
  const response = await GET(request);
  const reader = response.body?.getReader();

  const logEntry = { id: '1', message: 'test log', userId: '1' };
  (prisma.log.create as any).mockResolvedValue(logEntry);

  const decoder = new TextDecoder();
  await reader!.read().then(async ({ value }) => {
    const text = decoder.decode(value);
    expect(text).toBe('data: {"type":"connected"}\n\n');
  });

  await log('test log', '1');

  await reader!.read().then(async ({ value }) => {
    const text = decoder.decode(value);
    expect(text).toBe(`data: ${JSON.stringify(logEntry)}\n\n`);
  });

  reader!.cancel();
}, 30000);
