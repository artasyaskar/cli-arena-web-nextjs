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
  cron.schedule('0 0 * * *', pruneOldSessions);
}
