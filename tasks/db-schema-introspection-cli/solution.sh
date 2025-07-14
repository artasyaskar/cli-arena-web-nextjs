#!/bin/bash

# 1. Install dependencies
npm install pg @types/pg commander

# 2. Create the CLI tool
cat << 'EOF' > scripts/db-introspect.ts
#!/usr/bin/env node

import { Command } from 'commander';
import { Pool } from 'pg';

const program = new Command();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

program
  .command('tables')
  .description('List all tables in the database')
  .action(async () => {
    const res = await pool.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
    `);
    console.log(res.rows.map(row => row.table_name).join('\n'));
    await pool.end();
  });

program
  .command('columns <tableName>')
  .description('List all columns for a given table')
  .action(async (tableName) => {
    const res = await pool.query(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = $1
    `, [tableName]);
    console.log(res.rows.map(row => row.column_name).join('\n'));
    await pool.end();
  });

program.parse(process.argv);
EOF

# 3. Make the CLI tool executable
chmod +x scripts/db-introspect.ts

# 4. Add a new script to package.json
npm set-script db:introspect "ts-node scripts/db-introspect.ts"
