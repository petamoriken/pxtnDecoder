module.exports = {
  // for ES.next
  parser: "babel-eslint",
  parserOptions: {
    ecmaVersion: 8,
    sourceType: "module"
  },
  env: {
    "browser": true,
    "worker": true,
    "node": true,
    "commonjs": true
  },
  globals: {
    "ArrayBuffer": false,
    "Uint8Array": false,
  },
  // To give you an idea how to override rule options:
  extends: ["eslint:recommended"],
  rules: {
    "quotes": [2, "double", "avoid-escape"],
    "no-unused-vars": [1, {"vars": "all", "args": "after-used"}],
    "no-return-await": [1],
    "eol-last": [0],
    "no-mixed-requires": [0],
    "no-underscore-dangle": [0]
  }
};