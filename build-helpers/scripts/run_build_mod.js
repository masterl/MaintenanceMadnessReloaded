#!/usr/bin/env node
const path        = require('path');
const chalk       = require('chalk');

const build_mod = require('../src/build_mod');
const Factorio  = require('../src/Factorio');

const log = console.log;

const mods_to_build = [
  'maintenance-madness-reloaded'
];

const generate_mod_path = (mod_name) =>
{
  return path.resolve(path.join(__dirname, '..', '..', mod_name));
};

const main = async () =>
{
  try
  {
    const mods_folder = await Factorio.get_mods_folder();

    log('Building mods to folder:', chalk.green(mods_folder), '...');

    for (const mod_name of mods_to_build)
    {
      const mod_path = generate_mod_path(mod_name);

      log('Building mod', chalk.blue(mod_name), '...');
      await build_mod(mod_path, mods_folder);
      log(chalk.blue(mod_name), 'built sucessfully!');
    }
  }
  catch (error)
  {
    console.error('Couldn\'t build mods!');
    console.error(error);
  }
};

main();
