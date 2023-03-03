module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "quotes": ["error", "double"],
    "no-multiple-empty-lines": [2, {"max": 99999, "maxEOF": 0}],
  },
  parserOptions: {
    "ecmaVersion": 2020,
  },
};
