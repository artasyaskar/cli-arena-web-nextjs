import { expect, test, vi } from 'vitest';
import { pruneOldSessions, schedulePruneJob } from '@/jobs/prune-sessions';
import { prisma } from '@/lib/prisma';
import cron from 'node-cron';

vi.mock('node-cron', () => ({
  default: {
    schedule: vi.fn(),
  },
}));

vi.mock('@/lib/prisma', () => ({
  prisma: {
    session: {
      deleteMany: vi.fn(),
    },
  },
}));

test('should schedule the prune job', () => {
  schedulePruneJob();
  expect(cron.schedule).toHaveBeenCalledWith('0 0 * * *', pruneOldSessions);
});

test('should prune old sessions', async () => {
  await pruneOldSessions();
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);

  expect(prisma.session.deleteMany).toHaveBeenCalledWith({
    where: {
      expiresAt: {
        lt: expect.any(Date),
      },
    },
  });
});
