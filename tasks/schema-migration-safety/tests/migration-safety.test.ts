import { test, expect, vi } from 'vitest';
import { exec } from 'child_process';
import * as fs from 'fs';

const scriptPath = 'src/scripts/check-migration.ts';

function runScript(filePath: string): Promise<{ stdout: string; stderr: string; code: number }> {
  return new Promise(resolve => {
    exec(`npx tsx ${scriptPath} ${filePath}`, (error, stdout, stderr) => {
      resolve({ stdout, stderr, code: error?.code || 0 });
    });
  });
}

test('should pass for a safe migration', async () => {
  const safeSql = 'CREATE TABLE "new_table" (id INT);';
  fs.writeFileSync('safe-migration.sql', safeSql, 'utf8');

  const { stdout, code } = await runScript('safe-migration.sql');
  expect(stdout).toContain('Migration check passed.');
  expect(code).toBe(0);

  fs.unlinkSync('safe-migration.sql');
}, 30000);

test('should fail for a destructive migration', async () => {
  const destructiveSql = 'DROP TABLE "users";';
  fs.writeFileSync('destructive-migration.sql', destructiveSql, 'utf8');

  const { stdout, code } = await runScript('destructive-migration.sql');
  expect(stdout).toContain('Warning: Destructive migration detected!');
  expect(code).toBe(1);

  fs.unlinkSync('destructive-migration.sql');
}, 30000);
