'use server'

import { prisma } from '@/lib/prisma';
import { revalidatePath } from 'next/cache';

import { z } from 'zod';

const UserSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'String must contain at least 8 character(s)'),
});

export async function createUser(formData: FormData) {
  const validatedFields = UserSchema.safeParse({
    name: formData.get('name'),
    email: formData.get('email'),
    password: formData.get('password'),
  });

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
    };
  }

  const user = await prisma.user.create({
    data: validatedFields.data,
  });

  revalidatePath('/users');
  return { success: true, user };
}

export async function updateUser(id: string, formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  try {
    const user = await prisma.user.update({
      where: { id },
      data: {
        name,
        email,
      },
    });

    revalidatePath('/users');
    return { success: true, user };
  } catch {
    throw new Error('Failed to update user');
  }
}

export async function deleteUser(id: string) {
  try {
    await prisma.user.delete({
      where: { id },
    });

    revalidatePath('/users');
    return { success: true };
  } catch {
    throw new Error('Failed to delete user');
  }
}