import { expect, test, vi } from 'vitest';
import { Prisma } from '@prisma/client';

vi.mock('@prisma/client', async () => {
  const originalModule = await vi.importActual('@prisma/client');
  const PrismaClient = vi.fn().mockImplementation(() => ({
    $extends: vi.fn().mockReturnThis(), // Ensure $extends can be called
    user: {
      findUnique: vi.fn(),
    },
  }));
  return {
    ...originalModule,
    PrismaClient,
    Prisma: {
      ...originalModule.Prisma,
      PrismaClientKnownRequestError: class extends Error {
        code: string;
        constructor(message: string, code: string) {
          super(message);
          this.code = code;
        }
      },
    },
  };
});

test('should retry queries on database connection error', async () => {
  const { prisma } = await import('@/lib/prisma');
  const query = vi.fn();
  const error = new Prisma.PrismaClientKnownRequestError('Connection error', 'P1001');

  // Manually invoke the extension logic for testing
  const extendedQuery = prisma.$extends({
    query: {
      user: {
        async findUnique(params) {
          const maxRetries = 5;
          for (let i = 0; i < maxRetries; i++) {
            try {
              if (i < 4) {
                query();
                throw error;
              }
              return query(params.args);
            } catch (e) {
              if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P1001') {
                const delay = Math.pow(2, i) * 100;
                if (i === maxRetries - 1) throw e;
                await new Promise(res => setTimeout(res, delay));
              } else {
                throw e;
              }
            }
          }
        }
      }
    }
  });

  await extendedQuery.user.findUnique({ where: { id: '1' } });

  expect(query).toHaveBeenCalledTimes(5);
});
