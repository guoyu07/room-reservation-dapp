module.exports = {
  root: true,
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: 'babel-eslint',
    sourceType: 'module',
  },
  env: {
    browser: true,
  },
  extends: ['eslint:recommended', 'plugin:vue/recommended'],
  plugins: ['import'],
  globals: {
    process: true,
    cordova: true,
    DEV: true,
    PROD: true,
    __THEME: true,
  },
  rules: {
    'import/first': 0,
    'import/named': 2,
    'import/namespace': 2,
    'import/default': 2,
    'import/export': 2,
    'import/no-dynamic-require': 0,

    'global-require': 0,
    'function-paren-newline': 0,
    'no-empty-pattern': 0,
    'no-console': process.env.NODE_ENV === 'production' ? 1 : 0,
  },
};
