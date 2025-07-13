import { PrismaClient } from '@prisma/client';

declare global {
  var prisma: PrismaClient | undefined;
}

export const prisma = globalThis.prisma || new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalThis.prisma = prisma;
}

// Tenant middleware for multi-tenant functionality
export const tenantMiddleware = (params: any, next: Function) => {
  const tenantSpecificModels = ['Log', 'Document', 'Project']; // Add more as needed
  
  if (tenantSpecificModels.includes(params.model)) {
    // Add organizationId to where clause for tenant-specific models
    const modifiedParams = {
      ...params,
      args: {
        ...params.args,
        where: {
          ...params.args.where,
          organizationId: 'current_organization_id', // In real app, get from context
        },
      },
    };
    return next(modifiedParams);
  } else {
    // Pass through for non-tenant-specific models
    return next(params);
  }
};

export default prisma;