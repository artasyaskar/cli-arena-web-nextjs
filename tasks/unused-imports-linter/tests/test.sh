#!/bin/bash

# 1. Create a file with an unused import
mkdir -p src/test
cat << 'EOF' > src/test/unused.ts
import { useState } from 'react';
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({ message: 'Hello' });
}
EOF

# 2. Run the linter and check for an error
if npm run lint:unused; then
  echo "Unused imports linter test failed. Expected the linter to fail."
  exit 1
fi

# 3. Create a file with no unused imports
cat << 'EOF' > src/test/used.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({ message: 'Hello' });
}
EOF

# 4. Run the linter and check for success
if ! npm run lint:unused; then
  echo "Unused imports linter test failed. Expected the linter to pass."
  exit 1
fi

# 5. Clean up the test files
rm -rf src/test

echo "Unused imports linter test passed!"
exit 0
