#!/bin/bash

# 1. Install dependencies
npm install typescript

# 2. Create the linter script
cat << 'EOF' > scripts/lint-unused-imports.ts
#!/usr/bin/env node

import * as ts from 'typescript';
import * as glob from 'glob';
import * as fs from 'fs';

const ignoredImports = ['react'];

const files = glob.sync('src/**/*.{ts,tsx}');

let unusedImportsFound = false;

for (const file of files) {
  const sourceFile = ts.createSourceFile(
    file,
    fs.readFileSync(file).toString(),
    ts.ScriptTarget.ES2015,
    true
  );

  const imports = new Set<string>();

  ts.forEachChild(sourceFile, node => {
    if (ts.isImportDeclaration(node)) {
      const moduleSpecifier = (node.moduleSpecifier as ts.StringLiteral).text;
      if (!ignoredImports.includes(moduleSpecifier)) {
        if (node.importClause) {
          if (node.importClause.name) {
            imports.add(node.importClause.name.text);
          }
          if (node.importClause.namedBindings) {
            if (ts.isNamedImports(node.importClause.namedBindings)) {
              node.importClause.namedBindings.elements.forEach(element => {
                imports.add(element.name.text);
              });
            }
          }
        }
      }
    }
  });

  const usedIdentifiers = new Set<string>();
  function findUsages(node: ts.Node) {
    if (ts.isIdentifier(node)) {
      usedIdentifiers.add(node.text);
    }
    ts.forEachChild(node, findUsages);
  }
  findUsages(sourceFile);

  for (const imp of imports) {
    if (!usedIdentifiers.has(imp)) {
      console.error(`Unused import in ${file}: ${imp}`);
      unusedImportsFound = true;
    }
  }
}

if (unusedImportsFound) {
  process.exit(1);
}
EOF

# 3. Make the linter script executable
chmod +x scripts/lint-unused-imports.ts

# 4. Add a new script to package.json
npm set-script lint:unused "ts-node scripts/lint-unused-imports.ts"
