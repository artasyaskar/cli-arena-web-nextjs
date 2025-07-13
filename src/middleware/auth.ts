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

// Blacklist for invalidated tokens (in production, use Redis)
const tokenBlacklist = new Set<string>();

export function signToken(payload: Omit<JWTPayload, 'exp'>): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
}

export function verifyToken(token: string): JWTPayload | null {
  try {
    // Check if token is blacklisted
    if (tokenBlacklist.has(token)) {
      return null;
    }

    const decoded = jwt.verify(token, JWT_SECRET) as JWTPayload;
    return decoded;
  } catch (error) {
    return null;
  }
}

export function blacklistToken(token: string): void {
  tokenBlacklist.add(token);
}

export function authMiddleware(req: NextRequest): NextResponse | null {
  const authHeader = req.headers.get('authorization');
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return NextResponse.json(
      { error: 'Missing or invalid authorization header' },
      { status: 401 }
    );
  }

  const token = authHeader.substring(7);
  const payload = verifyToken(token);

  if (!payload) {
    return NextResponse.json(
      { error: 'Invalid or expired token' },
      { status: 401 }
    );
  }

  // Add user to request (in a real app, you'd extend the request type)
  (req as any).user = payload;
  
  return null; // Continue to next middleware/handler
}

export function requireAuth(handler: Function) {
  return async (req: NextRequest, ...args: any[]) => {
    const authError = authMiddleware(req);
    if (authError) {
      return authError;
    }
    return handler(req, ...args);
  };
}