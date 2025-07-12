#!/bin/bash

# Modify the Prisma schema
sed -i'' -e '/model User {/a \
  organizationId String\
  organization   Organization @relation(fields: [organizationId], references: [id])' db/prisma/schema.prisma

sed -i'' -e 's/sessions  Session\\[\\]/sessions  Session\\[\\]\
  organization   Organization? @relation(fields: [organizationId], references: [id])\
  organizationId String?/' db/prisma/schema.prisma

# Create Prisma middleware for multi-tenancy
mkdir -p src/lib
cat > src/lib/prisma.ts << EOL
import { PrismaClient } from '@prisma/client';

let prisma: PrismaClient;

if (process.env.NODE_ENV === 'production') {
  prisma = new PrismaClient();
} else {
  if (!global.prisma) {
    global.prisma = new PrismaClient();
  }
  prisma = global.prisma;
}

const tenantMiddleware = async (params, next) => {
  if (params.model === 'User' || params.model === 'Organization') {
    return next(params);
  }

  const organizationId = params.args?.where?.organizationId || 'current_organization_id'; // In a real app, get this from the user's session

  if (organizationId) {
    if (params.args?.where) {
      params.args.where.organizationId = organizationId;
    } else {
      params.args.where = { organizationId };
    }
  }
  return next(params);
};

prisma.$use(tenantMiddleware);

export { prisma };
EOL
