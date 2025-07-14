#!/bin/bash

# 1. Install dependencies
npm install crypto

# 2. Create the audit logging middleware
cat << 'EOF' > src/middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { createHmac } from 'crypto';

const prisma = new PrismaClient();
const secret = process.env.AUDIT_LOG_SECRET;

export async function middleware(req: NextRequest) {
  if (req.nextUrl.pathname.startsWith('/api/audit')) {
    return NextResponse.next();
  }

  const { method } = req;
  const url = req.nextUrl.clone();
  const body = await req.text();

  const logData = {
    method,
    url: url.pathname,
    body,
  };

  const signature = createHmac('sha256', secret)
    .update(JSON.stringify(logData))
    .digest('hex');

  await prisma.auditLog.create({
    data: {
      ...logData,
      signature,
    },
  });

  return NextResponse.next();
}

export const config = {
  matcher: '/api/:path*',
};
EOF

# 3. Create the audit log verification API
mkdir -p src/pages/api/audit
cat << 'EOF' > src/pages/api/audit/verify.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { PrismaClient } from '@prisma/client';
import { createHmac } from 'crypto';

const prisma = new PrismaClient();
const secret = process.env.AUDIT_LOG_SECRET;

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const logs = await prisma.auditLog.findMany();

  for (const log of logs) {
    const { method, url, body, signature } = log;
    const logData = { method, url, body };
    const expectedSignature = createHmac('sha256', secret)
      .update(JSON.stringify(logData))
      .digest('hex');

    if (signature !== expectedSignature) {
      return res.status(500).json({ message: 'Audit log integrity check failed' });
    }
  }

  res.status(200).json({ message: 'Audit log integrity check passed' });
}
EOF
