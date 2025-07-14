#!/bin/bash

# 1. Install dependencies
npm install apollo-server-micro graphql

# 2. Create the GraphQL schema and resolvers
mkdir -p src/graphql
cat << 'EOF' > src/graphql/schema.ts
import { gql } from 'apollo-server-micro';

export const typeDefs = gql`
  type Query {
    hello: String
  }
`;
EOF

cat << 'EOF' > src/graphql/resolvers.ts
export const resolvers = {
  Query: {
    hello: () => 'Hello, world!',
  },
};
EOF

# 3. Create the GraphQL API route
cat << 'EOF' > src/pages/api/graphql.ts
import { ApolloServer } from 'apollo-server-micro';
import { typeDefs } from '../../graphql/schema';
import { resolvers } from '../../graphql/resolvers';

const apolloServer = new ApolloServer({ typeDefs, resolvers });

export const config = {
  api: {
    bodyParser: false,
  },
};

const startServer = apolloServer.start();

export default async function handler(req, res) {
  await startServer;
  await apolloServer.createHandler({
    path: '/api/graphql',
  })(req, res);
}
EOF
