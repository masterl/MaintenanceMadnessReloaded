module.exports = {
  env: {
    commonjs: true,
    es2021:   true,
    node:     true
  },
  extends: [
    'standard'
  ],
  parserOptions: {
    ecmaVersion: 12
  },
  rules: {
    eqeqeq:                ['error', 'smart'],
    camelcase:             ['off', {
      properties: 'always'
    }],
    semi:                  ['error', 'always'],
    curly:                 'error',
    'prefer-const':        'warn',
    'no-const-assign':     'error',
    'no-var':              'error',
    'padded-blocks':       ['error', 'never'],
    'operator-assignment': ['error', 'always'],
    'no-cond-assign':      ['error', 'always'],
    'key-spacing':         [
      'error',
      {
        beforeColon: false,
        afterColon:  true,
        mode:        'minimum',
        align:       'value'
      }
    ],
    'no-multi-spaces': [
      'error',
      {
        exceptions: {
          VariableDeclarator: true
        }
      }
    ],
    'nonblock-statement-body-position': ['error', 'below'],
    'brace-style':                      ['error', 'allman']
  }
};
