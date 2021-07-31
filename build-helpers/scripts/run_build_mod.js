#!/usr/bin/env node
const path        = require('path');
const chalk       = require('chalk');

const build_mod = require('../src/build_mod');
const Factorio  = require('../src/Factorio');

const log = console.log;

const mods_to_build = [
  path.resolve('../../maintenance-madness-reloaded')
];

const main = async () =>
{
  try
  {
    const mods_folder = await Factorio.get_mods_folder();

    log('Building mods to folder:', chalk.green(mods_folder), '...');

    for (const mod_path of mods_to_build)
    {
      const mod_name = path.parse(mod_path).base;

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
