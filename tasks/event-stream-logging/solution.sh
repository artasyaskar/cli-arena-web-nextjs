#!/bin/bash

# Create the logger
mkdir -p src/lib
cat > src/lib/logger.ts << EOL
import { prisma } from './prisma';
import { EventEmitter } from 'events';

export const logEmitter = new EventEmitter();

export async function log(message: string, userId: string) {
  const logEntry = await prisma.log.create({
    data: {
      message,
      userId,
    },
  });
  logEmitter.emit('new-log', logEntry);
  return logEntry;
}
EOL

# Create the SSE route
mkdir -p src/app/api/logs/stream
cat > src/app/api/logs/stream/route.ts << EOL
import { NextRequest } from 'next/server';
import { logEmitter } from '@/lib/logger';

export async function GET(request: NextRequest) {
  const stream = new ReadableStream({
    start(controller) {
      const onLog = (log) => {
        controller.enqueue(\`data: \${JSON.stringify(log)}\\n\\n\`);
      };
      logEmitter.on('new-log', onLog);

      request.signal.addEventListener('abort', () => {
        logEmitter.removeListener('new-log', onLog);
        controller.close();
      });
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
EOL
