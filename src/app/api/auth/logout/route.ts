import { NextRequest, NextResponse } from 'next/server';
import { blacklistToken } from '@/middleware/auth';
import { prisma } from '@/lib/prisma';
import * as jwt from 'jsonwebtoken';

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      await blacklistToken(token);
      const decoded = jwt.decode(token) as { userId: string };
      if (decoded) {
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
    
    return NextResponse.json({
      message: 'Logout successful'
    });
  } catch {
    return NextResponse.json(
      { error: 'Logout failed' },
      { status: 500 }
    );
  }
}