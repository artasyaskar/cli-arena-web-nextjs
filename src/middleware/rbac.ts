import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import * as jwt from 'jsonwebtoken';

export interface UserRole {
  id: string;
  name: string;
  permissions: string[];
}

export interface User {
  id: string;
  email: string;
  roles: UserRole[];
}

export const checkPermission = (user: User, permission: string): boolean => {
  return user.roles.some(role => 
    role.permissions.includes(permission) || role.permissions.includes('*')
  );
};

export const requirePermission = (permission: string) => {
  return (req: NextRequest, user: User) => {
    if (!checkPermission(user, permission)) {
      return NextResponse.json(
        { error: 'Insufficient permissions' }, 
        { status: 403 }
      );
    }
    return null;
  };
};

export const rbacMiddleware = async (req: NextRequest) => {
  const url = new URL(req.url);
  
  // Check if this is an admin route
  if (url.pathname.startsWith('/admin')) {
    const authHeader = req.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Unauthorized - No authentication token' },
        { status: 401 }
      );
    }

    try {
      // Extract token from Bearer header
      const token = authHeader.substring(7);
      const jwtSecret = process.env.JWT_SECRET || 'secret';
      
      // Decode JWT token
      const decoded = jwt.verify(token, jwtSecret) as { userId: string };
      
      // Get user from database
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: { id: true, email: true, role: true }
      });

      if (!user) {
        return NextResponse.json(
          { error: 'User not found' },
          { status: 401 }
        );
      }

      // Check if user has admin role
      if (user.role !== 'ADMIN') {
        return NextResponse.json(
          { error: 'Forbidden - Insufficient permissions' },
          { status: 403 }
        );
      }
    } catch (error) {
      return NextResponse.json(
        { error: 'Invalid token' },
        { status: 401 }
      );
    }
  }

  return NextResponse.next();
};