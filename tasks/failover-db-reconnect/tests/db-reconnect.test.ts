import { expect, test, vi } from 'vitest';
import { Prisma } from '@prisma/client';

// Mock the PrismaClient
const mockPrismaClient = {
  $extends: vi.fn().mockReturnThis(),
  user: {
    findUnique: vi.fn(),
  },
};

vi.mock('@prisma/client', async () => {
  const originalModule = await vi.importActual('@prisma/client');
  return {
    ...originalModule,
    PrismaClient: vi.fn(() => mockPrismaClient),
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

beforeEach(() => {
  vi.clearAllMocks();
});

test('should retry queries on database connection error', async () => {
  const { prisma } = await import('@/lib/prisma');
  const query = mockPrismaClient.user.findUnique;
  const error = new Prisma.PrismaClientKnownRequestError('Connection error', 'P1001');

  // Simulate the extension logic
  let attempts = 0;
  const mockQuery = async () => {
    attempts++;
    if (attempts < 5) {
      throw error;
    }
    return { id: '1', name: 'Test User' };
  };
  query.mockImplementation(mockQuery);

  // Apply the extension
  const extendedPrisma = prisma.$extends({
    query: {
      user: {
        async findUnique(params) {
          const findUniqueWithRetry = async (retries: number): Promise<any> => {
            try {
              return await params.query(params.args);
            } catch (e) {
              if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P1001' && retries > 0) {
                const delay = Math.pow(2, 5 - retries) * 100;
                await new Promise(res => setTimeout(res, delay));
                return findUniqueWithRetry(retries - 1);
              }
              throw e;
            }
          };
          return findUniqueWithRetry(5);
        },
      },
    },
  });

  await expect(extendedPrisma.user.findUnique({ where: { id: '1' } })).rejects.toThrow('Connection error');

  expect(query).toHaveBeenCalledTimes(5);
});

test('should retry queries on database connection error', async () => {
  const { prisma } = await import('@/lib/prisma');
  const query = mockPrismaClient.user.findUnique;
  const error = new Prisma.PrismaClientKnownRequestError('Connection error', 'P1001');

  // Simulate the extension logic
  let attempts = 0;
  const mockQuery = async () => {
    attempts++;
    if (attempts < 5) {
      throw error;
    }
    return { id: '1', name: 'Test User' };
  };
  query.mockImplementation(mockQuery);

  // Apply the extension
  const extendedPrisma = prisma.$extends({
    query: {
      user: {
        async findUnique(params) {
          const findUniqueWithRetry = async (retries: number): Promise<any> => {
            try {
              return await params.query(params.args);
            } catch (e) {
              if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P1001' && retries > 0) {
                const delay = Math.pow(2, 5 - retries) * 100;
                await new Promise(res => setTimeout(res, delay));
                return findUniqueWithRetry(retries - 1);
              }
              throw e;
            }
          };
          return findUniqueWithRetry(5);
        },
      },
    },
  });

  await expect(extendedPrisma.user.findUnique({ where: { id: '1' } })).rejects.toThrow('Connection error');

  expect(query).toHaveBeenCalledTimes(5);
});
