import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const userId = searchParams.get('userId');

  if (!userId) {
    return NextResponse.json(
      { error: 'User ID is required' },
      { status: 400 }
    );
  }

  // Create readable stream for Server-Sent Events
  const stream = new ReadableStream({
    start(controller) {
      const encoder = new TextEncoder();
      const onLog = (logEntry: any) => {
        if (logEntry.userId === userId) {
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify(logEntry)}\n\n`)
          );
        }
      };

      logEmitter.on('log', onLog);

      // Send initial connection message
      controller.enqueue(encoder.encode('data: {"type":"connected"}\n\n'));

      request.signal.onabort = () => {
        logEmitter.off('log', onLog);
        controller.close();
      };
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}

export async function POST(request: NextRequest) {
  try {
    const { level, message, userId } = await request.json();
    
    // Create log entry
    const logEntry = await prisma.log.create({
      data: {
        level,
        message,
        userId,
        timestamp: new Date(),
      },
    });

    return NextResponse.json(logEntry);
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to create log entry' },
      { status: 500 }
    );
  }
}