#!/bin/bash

# Install dependencies
npm install csv-parse

# Create the API route for uploading users
mkdir -p src/app/api/users/upload
cat > src/app/api/users/upload/route.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { parse } from 'csv-parse';

export async function POST(request: NextRequest) {
  const reader = request.body?.getReader();
  if (!reader) {
    return new NextResponse('No body', { status: 400 });
  }

  const parser = parse({
    columns: true,
    skip_empty_lines: true,
  });

  const processBatch = async (batch) => {
    // In a real app, you should add error handling and validation
    await prisma.user.createMany({
      data: batch,
      skipDuplicates: true,
    });
  };

  let batch = [];
  const stream = new ReadableStream({
    async start(controller) {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        controller.enqueue(value);
      }
      controller.close();
    },
  });

  const textStream = stream.pipeThrough(new TextDecoderStream());

  for await (const chunk of textStream) {
    parser.write(chunk);
    for await (const record of parser) {
      batch.push(record);
      if (batch.length >= 100) {
        await processBatch(batch);
        batch = [];
      }
    }
  }

  if (batch.length > 0) {
    await processBatch(batch);
  }

  return NextResponse.json({ message: 'Upload successful' });
}
EOL
