#!/bin/bash

# 1. Create the monolithic API for the purpose of the task
mkdir -p src/pages/api
cat << 'EOF' > src/pages/api/monolith.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({ message: 'This is a monolithic API' });
}
EOF

# 2. Create the new directory for the RESTful modules
mkdir -p src/pages/api/v1

# 3. Create the users module
cat << 'EOF' > src/pages/api/v1/users.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    res.status(200).json({ message: 'Get all users' });
  } else if (req.method === 'POST') {
    res.status(201).json({ message: 'Create a new user' });
  } else {
    res.status(405).json({ message: 'Method Not Allowed' });
  }
}
EOF

# 4. Create the products module
cat << 'EOF' > src/pages/api/v1/products.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    res.status(200).json({ message: 'Get all products' });
  } else if (req.method === 'POST') {
    res.status(201).json({ message: 'Create a new product' });
  } else {
    res.status(405).json({ message: 'Method Not Allowed' });
  }
}
EOF

# 5. Create the orders module
cat << 'EOF' > src/pages/api/v1/orders.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    res.status(200).json({ message: 'Get all orders' });
  } else if (req.method === 'POST') {
    res.status(201).json({ message: 'Create a new order' });
  } else {
    res.status(405).json({ message: 'Method Not Allowed' });
  }
}
EOF

# 6. Deprecate the monolithic API
cat << 'EOF' > src/pages/api/monolith.ts
import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(410).json({ message: 'This API has been deprecated' });
}
EOF
