#!/bin/bash

# 1. Install dependencies
npm install aws-sdk multer @types/multer

# 3. Create the file upload API
mkdir -p src/pages/api/users
cat << 'EOF' > src/pages/api/users/avatar.ts
import { NextApiRequest, NextApiResponse } from 'next';
import multer from 'multer';
import { S3 } from 'aws-sdk';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const s3 = new S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  endpoint: process.env.S3_ENDPOINT,
  s3ForcePathStyle: true,
  signatureVersion: 'v4',
});

const upload = multer({
  storage: multer.memoryStorage(),
});

const uploadMiddleware = upload.single('avatar');

export const config = {
  api: {
    bodyParser: false,
  },
};

export default async function handler(req: NextApiRequest & { file: any }, res: NextApiResponse) {
  // This is a simplified example. In a real app, you'd get the user from the session.
  const userId = 1;

  uploadMiddleware(req as any, res as any, async (err) => {
    if (err) {
      return res.status(500).json({ message: 'File upload failed' });
    }

    const file = req.file;
    const key = `avatars/${userId}/${Date.now()}-${file.originalname}`;

    const params = {
      Bucket: process.env.S3_BUCKET_NAME,
      Key: key,
      Body: file.buffer,
    };

    try {
      const { Location } = await s3.upload(params).promise();
      await prisma.user.update({
        where: { id: userId },
        data: { avatarUrl: Location },
      });
      res.status(200).json({ avatarUrl: Location });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Failed to upload to S3' });
    }
  });
}
EOF
