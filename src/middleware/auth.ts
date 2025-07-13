import { NextRequest, NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';

export interface JWTPayload {
  userId: string;
  email: string;
  exp: number;
}

export interface AuthenticatedRequest extends NextRequest {
  user?: JWTPayload;
}

export const JWT_SECRET = process.env.JWT_SECRET || 'fallback-secret-key';

import { Redis } from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

export function signToken(payload: Omit<JWTPayload, 'exp'>): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
}

export async function verifyToken(token: string): Promise<JWTPayload | null> {
  try {
    // Check if token is blacklisted
    const isBlacklisted = await redis.get(`blacklist:${token}`);
    if (isBlacklisted) {
      return null;
    }

    const decoded = jwt.verify(token, JWT_SECRET) as JWTPayload;
    return decoded;
  } catch {
    return null;
  }
}

export async function blacklistToken(token: string): Promise<void> {
  try {
    const decoded = jwt.decode(token) as JWTPayload;
    if (decoded && decoded.exp) {
      const expiry = decoded.exp - Math.floor(Date.now() / 1000);
      await redis.set(`blacklist:${token}`, 'true', 'EX', expiry);
    }
  } catch {
    // Ignore errors
  }
}

export async function authMiddleware(req: NextRequest): Promise<NextResponse | null> {
  const authHeader = req.headers.get('authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return NextResponse.json(
      { error: 'Missing or invalid authorization header' },
      { status: 401 }
    );
  }

  const token = authHeader.substring(7);
  const payload = await verifyToken(token);

  if (!payload) {
    return NextResponse.json(
      { error: 'Invalid or expired token' },
      { status: 401 }
    );
  }

  // Add user to request (in a real app, you'd extend the request type)
  (req as AuthenticatedRequest).user = payload;
  
  return null; // Continue to next middleware/handler
}

type AuthenticatedHandler = (req: AuthenticatedRequest, ...args: any[]) => Promise<NextResponse>;

export function requireAuth(handler: AuthenticatedHandler) {
  return async (req: NextRequest, ...args: any[]) => {
    const authError = await authMiddleware(req);
    if (authError) {
      return authError;
    }
    return handler(req as AuthenticatedRequest, ...args);
  };
}