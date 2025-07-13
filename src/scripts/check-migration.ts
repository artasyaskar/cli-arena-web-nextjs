#!/usr/bin/env ts-node

import * as fs from 'fs';

const filePath = process.argv[2];

if (!filePath) {
  console.error('Usage: ts-node check-migration.ts <sql-file>');
  process.exit(1);
}

if (!fs.existsSync(filePath)) {
  console.error(`File not found: ${filePath}`);
  process.exit(1);
}

const sqlContent = fs.readFileSync(filePath, 'utf8').toLowerCase();

// Define destructive operations
const destructiveOperations = [
  'drop table',
  'drop column',
  'drop index',
  'alter table.*drop',
  'truncate',
  'delete from'
];

// Check for destructive operations
const isDestructive = destructiveOperations.some(operation => {
  const regex = new RegExp(operation, 'i');
  return regex.test(sqlContent);
});

if (isDestructive) {
  console.log('Warning: Destructive migration detected!');
  process.exit(1);
} else {
  console.log('Migration check passed.');
  process.exit(0);
}