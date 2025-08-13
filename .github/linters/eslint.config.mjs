// eslint.config.mjs
import eslintPluginJsonc from 'eslint-plugin-jsonc';
import jsoncParser from 'jsonc-eslint-parser';

export default [
  {
    files: ['**/*.json'],
    plugins: { jsonc: eslintPluginJsonc },
    languageOptions: {
      parser: jsoncParser,
      parserOptions: { jsonSyntax: 'JSONC' },
    },
    rules: { 'jsonc/no-comments': 'warn' },
  },
  {
    files: ['**/*.jsonc'],
    plugins: { jsonc: eslintPluginJsonc },
    languageOptions: {
      parser: jsoncParser,
      parserOptions: { jsonSyntax: 'JSONC' },
    },
  },
  {
    files: ['**/*.json5'],
    plugins: { jsonc: eslintPluginJsonc },
    languageOptions: {
      parser: jsoncParser,
      parserOptions: { jsonSyntax: 'JSON5' },
    },
  },
];
