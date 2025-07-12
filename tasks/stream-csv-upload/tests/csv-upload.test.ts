import { expect, test, vi } from 'vitest';
import { POST } from '@/app/api/users/upload/route';
import { NextRequest } from 'next/server';
import { prisma } from '@/lib/prisma';
import { Readable } from 'stream';

vi.mock('@/lib/prisma', () => ({
  prisma: {
    user: {
      createMany: vi.fn(),
    },
  },
}));

function createMockRequest(csvData: string): NextRequest {
  const readable = new Readable();
  readable._read = () => {}; // _read is required
  readable.push(csvData);
  readable.push(null); // No more data

  return new NextRequest('http://localhost/api/users/upload', {
    method: 'POST',
    body: readable as any,
  });
}

test('should process a CSV file and insert users in batches', async () => {
  let csvData = 'email,password\n';
  for (let i = 0; i < 150; i++) {
    csvData += `test${i}@example.com,password${i}\n`;
  }

  const request = createMockRequest(csvData);
  const response = await POST(request);

  expect(response.status).toBe(200);
  expect(prisma.user.createMany).toHaveBeenCalledTimes(2);
  expect(prisma.user.createMany).toHaveBeenCalledWith({
    data: expect.any(Array),
    skipDuplicates: true,
  });
  const firstCallArgs = (prisma.user.createMany as any).mock.calls[0][0];
  expect(firstCallArgs.data.length).toBe(100);
  const secondCallArgs = (prisma.user.createMany as any).mock.calls[1][0];
  expect(secondCallArgs.data.length).toBe(50);
});
