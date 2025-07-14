#!/bin/bash

# 1. Install dependencies
npm install next-auth @next-auth/prisma-adapter

# 2. Create the next-auth API route
mkdir -p src/pages/api/auth
cat << 'EOF' > src/pages/api/auth/[...nextauth].ts
import NextAuth from 'next-auth';
import GithubProvider from 'next-auth/providers/github';
import { PrismaAdapter } from '@next-auth/prisma-adapter';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export default NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    GithubProvider({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    }),
  ],
  callbacks: {
    async signIn({ user, account, profile }) {
      const existingUser = await prisma.user.findUnique({
        where: { email: user.email },
      });

      if (existingUser) {
        await prisma.user.update({
          where: { email: user.email },
          data: { githubId: profile.id.toString() },
        });
      }

      return true;
    },
  },
});
EOF
