import { expect, test, vi } from 'vitest';
import { createUser } from '@/app/actions';
import { prisma } from '@/lib/prisma';

vi.mock('@/lib/prisma', () => ({
  prisma: {
    user: {
      create: vi.fn(),
    },
  },
}));

vi.mock('next/cache', () => ({
  revalidatePath: vi.fn(),
}));

beforeEach(() => {
  vi.clearAllMocks();
});

vi.mock('next/cache', () => ({
  revalidatePath: vi.fn(),
}));

test('should create a user with valid data', async () => {
  const formData = new FormData();
  formData.append('name', 'Test User');
  formData.append('email', 'test@example.com');
  formData.append('password', 'password123');

  const user = { id: '1', name: 'Test User', email: 'test@example.com', password: 'password123' };
  (prisma.user.create as any).mockResolvedValue(user);

  const result = await createUser(formData);

  expect(result.success).toBe(true);
  expect(result.user).toEqual(user);
  expect(prisma.user.create).toHaveBeenCalledWith({
    data: {
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
    },
  });
});

test('should return errors with invalid data', async () => {
  const formData = new FormData();
  formData.append('name', 'Test User');
  formData.append('email', 'invalid-email');
  formData.append('password', 'short');

  const result = await createUser(formData);

  expect(result.errors).toBeDefined();
  expect(result.errors?.email).toEqual(['Invalid email']);
  expect(result.errors?.password).toEqual(['String must contain at least 8 character(s)']);
});
