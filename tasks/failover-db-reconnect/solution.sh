#!/bin/bash

# Create the Prisma client extension for retrying queries
mkdir -p src/lib
cat > src/lib/prisma.ts << EOL
import { Prisma, PrismaClient } from '@prisma/client';

const prisma = new PrismaClient().$extends({
  query: {
    $allModels: {
      async $allOperations({ model, operation, args, query }) {
        const maxRetries = 5;
        for (let i = 0; i < maxRetries; i++) {
          try {
            return await query(args);
          } catch (error) {
            if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P1001') {
              const delay = Math.pow(2, i) * 100; // Exponential backoff
              if (i === maxRetries - 1) throw error;
              await new Promise(res => setTimeout(res, delay));
            } else {
              throw error;
            }
          }
        }
      },
    },
  },
});

export { prisma };
EOL
