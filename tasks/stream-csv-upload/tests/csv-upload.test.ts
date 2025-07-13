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
  const formData = new FormData();
  const blob = new Blob([csvData], { type: 'text/csv' });
  formData.append('file', blob, 'users.csv');

  return new NextRequest('http://localhost/api/users/upload', {
    method: 'POST',
    body: formData,
  });
}

beforeEach(() => {
  vi.clearAllMocks();
});

test('should process a CSV file and insert users in batches', async () => {
  let csvData = 'email,password\n';
  for (let i = 0; i < 50; i++) {
    csvData += `test${i}@example.com,password${i}\n`;
  }

  const request = createMockRequest(csvData);
  const response = await POST(request);

  expect(response.status).toBe(200);
  expect(prisma.user.createMany).toHaveBeenCalledTimes(1);
  expect(prisma.user.createMany).toHaveBeenCalledWith({
    data: expect.any(Array),
    skipDuplicates: true,
  });
  const firstCallArgs = (prisma.user.createMany as any).mock.calls[0][0];
  expect(firstCallArgs.data.length).toBe(50);
}, 960000);
