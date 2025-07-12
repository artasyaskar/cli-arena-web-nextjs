#!/bin/bash

# Modify the Prisma schema to include the AuditLog model
sed -i'' -e '/model Log {/a \
model AuditLog {\
  id        String   @id @default(cuid())\
  userId    String\
  user      User     @relation(fields: [userId], references: [id])\
  action    String\
  ipAddress String?\
  userAgent String?\
  createdAt DateTime @default(now())\
}' db/prisma/schema.prisma

# Update the User model to have a relation to AuditLog
sed -i'' -e '/logs      Log\\[\\]/a \
  auditLogs AuditLog\\[\\]' db/prisma/schema.prisma


# Create the login route with audit logging
mkdir -p src/app/api/auth/login
cat > src/app/api/auth/login/route.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import * as jwt from 'jsonwebtoken';

export async function POST(request: NextRequest) {
  const { email, password } = await request.json();
  // In a real app, you would validate the password
  const user = await prisma.user.findUnique({ where: { email } });

  if (user) {
    await prisma.auditLog.create({
      data: {
        userId: user.id,
        action: 'login',
        ipAddress: request.ip,
        userAgent: request.headers.get('user-agent'),
      },
    });

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!, { expiresIn: '1h' });
    const refreshToken = jwt.sign({ userId: user.id }, process.env.REFRESH_SECRET!, { expiresIn: '7d' });

    return NextResponse.json({ token, refreshToken });
  }

  return new NextResponse('Unauthorized', { status: 401 });
}
EOL

# Create the logout route with audit logging
mkdir -p src/app/api/auth/logout
cat > src/app/api/auth/logout/route.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import * as jwt from 'jsonwebtoken';

export async function POST(request: NextRequest) {
    const token = request.headers.get('authorization')?.split(' ')[1];
    if(token) {
        const decoded = jwt.decode(token) as { userId?: string };
        if (decoded?.userId) {
            await prisma.auditLog.create({
                data: {
                userId: decoded.userId,
                action: 'logout',
                ipAddress: request.ip,
                userAgent: request.headers.get('user-agent'),
                },
            });
        }
    }
  return NextResponse.json({ message: 'Logged out' });
}
EOL

# Create the refresh route with audit logging
mkdir -p src/app/api/auth/refresh
cat > src/app/api/auth/refresh/route.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import * as jwt from 'jsonwebtoken';

export async function POST(request: NextRequest) {
  const { refreshToken } = await request.json();

  try {
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_SECRET!) as { userId: string };

    await prisma.auditLog.create({
        data: {
          userId: decoded.userId,
          action: 'refresh_token',
          ipAddress: request.ip,
          userAgent: request.headers.get('user-agent'),
        },
      });

    const token = jwt.sign({ userId: decoded.userId }, process.env.JWT_SECRET!, { expiresIn: '1h' });
    return NextResponse.json({ token });

  } catch (error) {
    return new NextResponse('Unauthorized', { status: 401 });
  }
}
EOL
