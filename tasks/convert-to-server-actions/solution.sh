#!/bin/bash

# Install dependencies
npm install zod

# Create actions.ts file
cat > src/app/actions.ts << EOL
'use server';

import { z } from 'zod';
import { prisma } from '@/lib/prisma';

const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export async function createUser(formData: FormData) {
  const validatedFields = userSchema.safeParse(Object.fromEntries(formData.entries()));

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
    };
  }

  const { email, password } = validatedFields.data;

  try {
    const user = await prisma.user.create({
      data: {
        email,
        password, // In a real app, hash the password
      },
    });
    return { user };
  } catch (error) {
    return {
      errors: {
        database: ['Failed to create user.'],
      },
    };
  }
}
EOL

# Create placeholder API routes
mkdir -p src/app/api/user/create
cat > src/app/api/user/create/route.ts << EOL
// This route is now handled by a server action.
// You can remove this file.
import { NextResponse } from 'next/server';
export async function POST() {
  return NextResponse.json({ message: 'This route has been deprecated.' });
}
EOL

mkdir -p src/app/api/user/update
cat > src/app/api/user/update/route.ts << EOL
// This route is now handled by a server action.
// You can remove this file.
import { NextResponse } from 'next/server';
export async function POST() {
  return NextResponse.json({ message: 'This route has been deprecated.' });
}
EOL
