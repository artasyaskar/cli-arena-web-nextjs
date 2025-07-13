'use server'

import { prisma } from '@/lib/prisma';
import { revalidatePath } from 'next/cache';

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  if (!name || !email) {
    throw new Error('Name and email are required');
  }

  try {
    const user = await prisma.user.create({
      data: {
        name,
        email,
      },
    });

    revalidatePath('/users');
    return { success: true, user };
  } catch (error) {
    throw new Error('Failed to create user');
  }
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
  } catch (error) {
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
  } catch (error) {
    throw new Error('Failed to delete user');
  }
}