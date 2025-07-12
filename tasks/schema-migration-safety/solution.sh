#!/bin/bash

# Create the CLI tool for checking migrations
mkdir -p src/scripts
cat > src/scripts/check-migration.ts << EOL
#!/usr/bin/env ts-node

import * as fs from 'fs';

function checkMigration(filePath: string): void {
  const destructivePatterns = [
    /DROP TABLE/i,
    /DROP COLUMN/i,
    /TRUNCATE/i,
    /ALTER TABLE .* DROP CONSTRAINT/i,
  ];

  const sql = fs.readFileSync(filePath, 'utf-8');
  const foundDestructive = destructivePatterns.some(pattern => pattern.test(sql));

  if (foundDestructive) {
    console.warn('Warning: Destructive migration detected!');
    process.exit(1);
  } else {
    console.log('Migration check passed.');
    process.exit(0);
  }
}

if (require.main === module) {
  const filePath = process.argv[2];
  if (!filePath) {
    console.error('Usage: ts-node check-migration.ts <path-to-migration.sql>');
    process.exit(1);
  }
  checkMigration(filePath);
}
EOL

# Make the script executable
chmod +x src/scripts/check-migration.ts
