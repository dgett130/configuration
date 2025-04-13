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
