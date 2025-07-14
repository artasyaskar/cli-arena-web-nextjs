#!/bin/bash

# 1. Create the sitemap generation API
mkdir -p src/pages/api
cat << 'EOF' > src/pages/api/sitemap.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const users = await prisma.user.findMany();
  const baseUrl = req.headers.host ? `http://${req.headers.host}` : '';

  const sitemap = `
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url>
        <loc>${baseUrl}/</loc>
      </url>
      ${users
        .map(
          (user) => `
        <url>
          <loc>${baseUrl}/users/${user.id}</loc>
        </url>
      `
        )
        .join('')}
    </urlset>
  `;

  res.setHeader('Content-Type', 'text/xml');
  res.write(sitemap);
  res.end();
}
EOF

# 2. Add a rewrite to next.config.js for the sitemap
cat << 'EOF' > next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  async rewrites() {
    return [
      {
        source: '/sitemap.xml',
        destination: '/api/sitemap',
      },
    ];
  },
};

module.exports = nextConfig;
EOF

# 3. Create the SEO metadata component
mkdir -p src/components
cat << 'EOF' > src/components/Seo.tsx
import Head from 'next/head';

interface SeoProps {
  title: string;
  description: string;
}

const Seo = ({ title, description }: SeoProps) => {
  return (
    <Head>
      <title>{title}</title>
      <meta name="description" content={description} />
      <meta property="og:title" content={title} />
      <meta property="og:description" content={description} />
    </Head>
  );
};

export default Seo;
EOF
