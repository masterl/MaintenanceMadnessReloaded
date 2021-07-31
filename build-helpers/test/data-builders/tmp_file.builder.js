const tmp       = require('tmp-promise');
const fs        = require('fs/promises');
const { isNil } = require('lodash/fp');
const faker     = require('faker');
const path      = require('path');

module.exports = {
  create_one
};

function get_file_options (options = {})
{
  return {
    keep:    options.keep || false,
    mode:    options.mode || 0o600,
    prefix:  options.prefix || 'test_file_',
    dir:     path.resolve(options.dir || '/tmp'),
    postfix: options.postfix || '.tmp'
  };
}

function create_one (options = {})
{
  let file_contents = options.contents;

  if (isNil(options.contents))
  {
    file_contents = faker.lorem.text;
  }

  const file_options = get_file_options(options);

  const return_value = {
    path: '',
    file_contents
  };

  return tmp.file(file_options)
    .then(({ path }) => (return_value.path = path))
    .then(path => fs.writeFile(path, file_contents))
    .then(() => return_value);
};
