import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Check if user already exists
  const existingUser = await prisma.user.findUnique({
    where: { email: 'test@example.com' },
  });

  if (!existingUser) {
    await prisma.user.create({
      data: {
        email: 'test@example.com',
        password: 'password',
      },
    });
    console.log('✅ User created');
  } else {
    console.log('⚠️ User already exists. Skipping user creation.');
  }

  // Check if organization already exists
  const existingOrg = await prisma.organization.findFirst({
    where: { name: 'Test Organization' },
  });

  if (!existingOrg) {
    await prisma.organization.create({
      data: {
        name: 'Test Organization',
      },
    });
    console.log('✅ Organization created');
  } else {
    console.log('⚠️ Organization already exists. Skipping organization creation.');
  }
}

main()
  .catch((e) => {
    console.error('❌ Error in seed script:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
