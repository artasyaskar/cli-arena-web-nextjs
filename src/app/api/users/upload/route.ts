import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { Readable } from 'stream';

interface UserData {
  [key: string]: string;
}

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File;

    if (!file) {
      return NextResponse.json({ error: 'No file provided' }, { status: 400 });
    }

    const stream = Readable.from(file.stream());

    let buffer = '';
    let headers: string[] = [];
    const users: UserData[] = [];
    const batchSize = 50;

    for await (const chunk of stream) {
      buffer += chunk.toString();
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';

      if (headers.length === 0) {
        headers = lines.shift()?.split(',') || [];
      }

      for (const line of lines) {
        if (line.trim()) {
          const values = line.split(',');
          const user: UserData = {};
          headers.forEach((header, index) => {
            user[header.trim()] = values[index]?.trim();
          });
          users.push(user);

          if (users.length >= batchSize) {
            await prisma.user.createMany({
              data: users,
              skipDuplicates: true,
            });
            users.length = 0;
          }
        }
      }
    }

    if (users.length > 0) {
      await prisma.user.createMany({
        data: users,
        skipDuplicates: true,
      });
    }

    return NextResponse.json({
      message: 'CSV processed successfully',
    });
  } catch {
    return NextResponse.json(
      { error: 'Upload failed' },
      { status: 500 }
    );
  }
}