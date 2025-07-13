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
      
      // Send initial connection message
      controller.enqueue(encoder.encode('data: {"type":"connected"}\n\n'));
      
      // Simulate streaming logs
      const interval = setInterval(async () => {
        try {
          // In a real app, you'd stream actual logs from database
          const logEntry = {
            id: Math.random().toString(36),
            timestamp: new Date().toISOString(),
            level: 'info',
            message: `Log entry for user ${userId}`,
            userId: userId
          };
          
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify(logEntry)}\n\n`)
          );
        } catch (error) {
          console.error('Error streaming logs:', error);
        }
      }, 1000);

      // Clean up after 30 seconds
      setTimeout(() => {
        clearInterval(interval);
        controller.close();
      }, 30000);
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
}import { NextRequest, NextResponse } from 'next/server';
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
      
      // Send initial connection message
      controller.enqueue(encoder.encode('data: {"type":"connected"}\n\n'));
      
      // Simulate streaming logs
      const interval = setInterval(async () => {
        try {
          // In a real app, you'd stream actual logs from database
          const logEntry = {
            id: Math.random().toString(36),
            timestamp: new Date().toISOString(),
            level: 'info',
            message: `Log entry for user ${userId}`,
            userId: userId
          };
          
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify(logEntry)}\n\n`)
          );
        } catch (error) {
          console.error('Error streaming logs:', error);
        }
      }, 1000);

      // Clean up after 30 seconds
      setTimeout(() => {
        clearInterval(interval);
        controller.close();
      }, 30000);
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