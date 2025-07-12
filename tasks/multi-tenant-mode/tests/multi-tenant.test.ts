import { expect, test, vi } from 'vitest';
import { prisma } from '@/lib/prisma';

vi.mock('@prisma/client', () => {
  const mPrismaClient = {
    $use: vi.fn(),
    log: {
      findMany: vi.fn(),
    },
  };
  return { PrismaClient: vi.fn(() => mPrismaClient) };
});

test('should add organizationId to where clause for tenant-specific models', async () => {
  const { tenantMiddleware } = await import('@/lib/prisma.ts');

  const next = vi.fn();
  const params = {
    model: 'Log',
    action: 'findMany',
    args: {
      where: { userId: '1' },
    },
  };

  await (tenantMiddleware as any)(params, next);

  expect(next).toHaveBeenCalledWith({
    model: 'Log',
    action: 'findMany',
    args: {
      where: {
        userId: '1',
        organizationId: 'current_organization_id',
      },
    },
  });
});

test('should not add organizationId to where clause for non-tenant-specific models', async () => {
  const { tenantMiddleware } = await import('@/lib/prisma.ts');

  const next = vi.fn();
  const params = {
    model: 'User',
    action: 'findUnique',
    args: {
      where: { id: '1' },
    },
  };

  await (tenantMiddleware as any)(params, next);

  expect(next).toHaveBeenCalledWith(params);
});
