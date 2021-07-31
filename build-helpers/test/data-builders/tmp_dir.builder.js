const tmp                = require('tmp-promise');
const { partial, range } = require('lodash/fp');
const Bluebird           = require('bluebird');
const fs                 = require('fs/promises');
const path               = require('path');

const TmpFileBuilder     = require('./tmp_file.builder');

tmp.setGracefulCleanup();

module.exports = {
  create_one_empty,
  create_one_with_files
};

class TmpDir
{
  constructor (directory_path = '', inner_files = [])
  {
    this._path = directory_path;
    this._inner_files = inner_files;
  }

  set path (new_path)
  {
    this._path = new_path;
  }

  get path ()
  {
    return this._path;
  }

  set inner_files (new_files)
  {
    this._inner_files = new_files;
  }

  get inner_files ()
  {
    return this._inner_files;
  }

  create_file_inside (filename, contents = '')
  {
    const file_path = path.join(this._path, filename);

    const file_info = {
      path: file_path,
      contents
    };

    return fs.writeFile(file_path, contents)
      .then(() => this.inner_files.push(file_info));
  }
}

function get_directory_options (options = {})
{
  return {
    keep:          options.keep || false,
    mode:          options.mode || 0o750,
    prefix:        options.prefix || 'test_dir_',
    dir:           options.dir,
    unsafeCleanup: options.unsafeCleanup || true
  };
}

function create_one_empty (options = {})
{
  options = get_directory_options(options);

  return tmp.dir(options);
}

function get_inner_files_options (dir_path, options = {})
{
  return {
    keep:     options.file_keep || false,
    mode:     options.file_mode || 0o600,
    dir:      `${dir_path}/`,
    postfix:   options.file_extension || '.tmp',
    contents: options.file_contents || ''
  };
}

function create_one_with_files (file_count = 3, options = {})
{
  const dir_options = get_directory_options(options);
  let file_options;

  const dir_info = new TmpDir();

  return create_one_empty(dir_options)
    .then(({ path }) =>
    {
      dir_info.path = path;
      file_options = get_inner_files_options(dir_info.path, options);

      const create_new_file = partial(TmpFileBuilder.create_one, [file_options]);

      return Bluebird.map(range(0, file_count), create_new_file);
    })
    .then(files => (dir_info.inner_files = files))
    .then(() => dir_info);
}
