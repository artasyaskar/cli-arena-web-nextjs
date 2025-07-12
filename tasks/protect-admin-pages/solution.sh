#!/bin/bash

# Modify the Prisma schema to add a role to the User model
sed -i'' -e '/password  String/a \
  role      Role     @default(USER)' db/prisma/schema.prisma

# Add the Role enum to the schema
echo '
enum Role {
  USER
  ADMIN
}' >> db/prisma/schema.prisma

# Create the RBAC middleware
mkdir -p src/middleware
cat > src/middleware/rbac.ts << EOL
import { NextRequest, NextResponse } from 'next/server';
import * as jwt from 'jsonwebtoken';
import { prisma } from '@/lib/prisma';

export async function rbacMiddleware(request: NextRequest) {
  const token = request.headers.get('authorization')?.split(' ')[1];

  if (!token) {
    return new NextResponse('Unauthorized', { status: 401 });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { userId: string };
    const user = await prisma.user.findUnique({ where: { id: decoded.userId } });

    if (user?.role !== 'ADMIN') {
      return new NextResponse('Forbidden', { status: 403 });
    }

    return NextResponse.next();
  } catch (error) {
    return new NextResponse('Unauthorized', { status: 401 });
  }
}
EOL

# Create a placeholder admin page
mkdir -p src/app/admin
cat > src/app/admin/page.tsx << EOL
export default function AdminPage() {
  return <h1>Admin Dashboard</h1>;
}
EOL
