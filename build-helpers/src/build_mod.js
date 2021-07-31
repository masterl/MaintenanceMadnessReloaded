const { zip }      = require('zip-a-folder');
const path         = require('path');
const { readFile } = require('fs/promises');

const load_mod_info = (source_folder) =>
{
  const info_path = path.join(source_folder, 'info.json');

  return readFile(info_path)
    .then(JSON.parse);
};

const generate_zip_name = (mod_info) =>
{
  return `${mod_info.name}_${mod_info.version}.zip`;
};

const build_mod = (source_folder, build_folder) =>
{
  return load_mod_info(source_folder)
    .then(generate_zip_name)
    .then(zip_name => path.join(build_folder, zip_name))
    .then(zip_path => zip(source_folder, zip_path));
};

module.exports = build_mod;
