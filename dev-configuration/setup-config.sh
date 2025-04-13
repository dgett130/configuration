#!/bin/bash

# 🛑 Exit on any error
set -e

echo "📦 Installing dev dependencies..."
npm install --save-dev \
  husky lint-staged prettier \
  @commitlint/cli @commitlint/config-conventional \
  commitizen git-cz cz-conventional-changelog \
  conventional-changelog conventional-changelog-cli \
  conventional-changelog-writer \
  @eslint/js eslint eslint-plugin-react \
  cross-env


echo "📂 Initializing husky..."
npx husky install
npm pkg set scripts.prepare="husky install"

echo "🧩 Running husky init..."
npx husky init

# Overwrite pre-commit hook
echo "🧼 Adding pre-commit hook..."
echo '
npx lint-staged
' > .husky/pre-commit
chmod +x .husky/pre-commit

# Overwrite commit-msg hook
echo "🧼 Adding commit-msg hook..."
echo "npx --no-install commitlint --edit \$1" > .husky/commit-msg
chmod +x .husky/commit-msg

echo "✅ Husky hooks set up!"

echo "🧼 Creating .lintstagedrc.json..."
cat > .lintstagedrc.json << 'EOF'
{
  "*.{js,jsx,ts,tsx,json}": ["prettier --write"]
}
EOF

echo "🎨 Creating .prettierrc..."
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "singleQuote": false,
  "printWidth": 80,
  "trailingComma": "es5"
}
EOF

echo "🧾 Creating commitlint.config.js..."
cat > commitlint.config.js << 'EOF'
module.exports = {
  extends: ["@commitlint/config-conventional"]
};
EOF

echo "📘 Creating custom changelog config..."
cat > conventional-changelog-config.js << 'EOF'
module.exports = {
  preset: 'angular',
  releaseCount: 0,
  writerOpts: {
    headerPartial: '## 🎉 Project v{{version}}\n\n_Release date: {{date}}_\n',
    transform: (commit, context) => {
      const typeMap = {
        feat: '✨ Features',
        chore: '🔧 Chores',
      };
      const newType = typeMap[commit.type];
      if (!newType) return;
      commit.type = newType;
      return commit;
    },
    groupBy: 'type',
    commitGroupsSort: (a, b) => {
      const order = ['✨ Features', '🔧 Chores'];
      return order.indexOf(a.title) - order.indexOf(b.title);
    },
  },
};
EOF

echo "📗 Creating ESLint flat config..."
cat > eslint.config.mjs << 'EOF'
import { defineConfig } from "eslint/config";
import js from "@eslint/js";
import pluginReact from "eslint-plugin-react";
import globals from "globals";

export default defineConfig([
  {
    files: ["**/*.{js,jsx,ts,tsx}"],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node
      },
    },
    plugins: {
      react: pluginReact,
    },
    rules: {
      "react/react-in-jsx-scope": "off"
    }
  },
  js.configs.recommended,
  pluginReact.configs.recommended,
]);
EOF

echo "🔧 Updating package.json scripts..."
npm pkg set scripts.commit="cross-env CZ_RUNNING=true git cz"
npm pkg set scripts.changelog="node ./scripts/generate-changelog.mjs"
npm pkg set scripts.lint="eslint . --max-warnings=0"

echo "🧱 Setting commitizen config..."
npm pkg set config.commitizen.path="git-cz"
npm pkg set config.cz-changelog.path="./conventional-changelog-config.js"

echo "📝 Creating scripts/generate-changelog.mjs..."
mkdir -p scripts
cat > scripts/generate-changelog.mjs << 'EOF'
import fs from "fs";
import { fileURLToPath } from "url";
import path from "path";
import conventionalChangelog from "conventional-changelog";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const changelogPath = path.join(__dirname, "..", "CHANGELOG.md");
const output = fs.createWriteStream(changelogPath);

conventionalChangelog(
  {
    config: await import("../conventional-changelog-config.js").then(m => m.default || m),
    releaseCount: 0
  },
  null,
  null,
  null,
  null
).pipe(output);
EOF

echo "✅ Setup complete. Run 'git init' and you're ready to go!"
