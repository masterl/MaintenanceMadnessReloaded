const { zip }      = require('zip-a-folder');
const path         = require('path');
const { readFile } = require('fs/promises');
const fse          = require('fs-extra');
const tmp          = require('tmp-promise');

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

const generate_tmp_folder = () =>
{
  return tmp.dir({
    keep:          false,
    mode:          0o750,
    unsafeCleanup: true
  })
    .then(({ path }) => path);
};

const copy_mod_to_tmp_folder = async (source_folder) =>
{
  const { base } = path.parse(source_folder);

  const tmp_folder = await generate_tmp_folder();

  await fse.copy(source_folder, path.join(tmp_folder, base));

  return tmp_folder;
};

const build_mod = async (source_folder, build_folder) =>
{
  let tmp_folder;

  return copy_mod_to_tmp_folder(source_folder)
    .then(folder => (tmp_folder = folder))
    .then(() => load_mod_info(source_folder))
    .then(generate_zip_name)
    .then(zip_name => path.join(build_folder, zip_name))
    .then(zip_path => zip(tmp_folder, zip_path));
};

module.exports = build_mod;
