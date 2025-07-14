#!/bin/bash

# 1. Install dependencies
npm install otplib qrcode @types/qrcode

# 2. Create the 2FA setup and verification APIs
mkdir -p src/pages/api/auth
cat << 'EOF' > src/pages/api/auth/2fa-setup.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { authenticator } from 'otplib';
import qrcode from 'qrcode';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  // This is a simplified example. In a real app, you'd get the user from the session.
  const userId = 1;

  const secret = authenticator.generateSecret();
  const otpauth = authenticator.keyuri(
    'user@example.com',
    'My App',
    secret
  );

  await prisma.user.update({
    where: { id: userId },
    data: { twoFactorSecret: secret },
  });

  const qrCodeDataUrl = await qrcode.toDataURL(otpauth);

  res.status(200).json({ qrCodeDataUrl, secret });
}
EOF

cat << 'EOF' > src/pages/api/auth/2fa-verify.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { authenticator } from 'otplib';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { token } = req.body;
  // This is a simplified example. In a real app, you'd get the user from the session.
  const userId = 1;

  const user = await prisma.user.findUnique({ where: { id: userId } });

  if (!user || !user.twoFactorSecret) {
    return res.status(400).json({ message: '2FA not enabled' });
  }

  const isValid = authenticator.check(token, user.twoFactorSecret);

  if (isValid) {
    res.status(200).json({ message: 'Login successful' });
  } else {
    res.status(401).json({ message: 'Invalid 2FA token' });
  }
}
EOF
