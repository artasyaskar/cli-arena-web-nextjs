#!/bin/bash

# 1. Install dependencies
npm install openai

# 2. Create the summarize API
mkdir -p src/pages/api
cat << 'EOF' > src/pages/api/summarize.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { OpenAI } from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { url } = req.body;

  try {
    const response = await fetch(url);
    const html = await response.text();
    // In a real app, you would use a library like cheerio to extract the article text
    const articleText = html;

    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: 'You are a helpful assistant that summarizes articles.',
        },
        {
          role: 'user',
          content: `Summarize the following article:\n\n${articleText}`,
        },
      ],
    });

    res.status(200).json({ summary: completion.choices[0].message.content });
  } catch (error) {
    res.status(500).json({ message: 'Failed to summarize article' });
  }
}
EOF
