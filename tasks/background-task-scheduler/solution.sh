#!/bin/bash

# Install dependencies
npm install node-cron @types/node-cron

# Create the job script
mkdir -p src/jobs
cat > src/jobs/prune-sessions.ts << EOL
import { prisma } from '@/lib/prisma';
import cron from 'node-cron';

export async function pruneOldSessions() {
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);

  await prisma.session.deleteMany({
    where: {
      expiresAt: {
        lt: yesterday,
      },
    },
  });
}

export function schedulePruneJob() {
    // Schedule to run once a day at midnight
  cron.schedule('0 0 * * *', pruneOldSessions);
}
EOL

# Create a server file to start the job
cat > src/app/server.ts << EOL
import { schedulePruneJob } from '@/jobs/prune-sessions';

console.log('Starting server...');
schedulePruneJob();
console.log('Session pruning job scheduled.');

// In a real Next.js app, you would integrate this with the app's startup process.
// For this task, this file simulates the server startup.
EOL
