const { constants } = require('fs');
const { access }    = require('fs/promises');
const path          = require('path');
const os            = require('os');

const get_linux_mods_folder = () =>
{
  const default_folder = path.join(os.homedir(), '.factorio', 'mods');

  return access(default_folder, constants.R_OK | constants.W_OK | constants.X_OK)
    .then(() => default_folder);
};

class Factorio
{
  static get_mods_folder ()
  {
    const { platform } = process;

    switch (platform)
    {
      case 'linux':
        return get_linux_mods_folder();
      // TODO: add Windows version
      // case 'win32':
      //   return get_windows_mod_folder();
      default:
        return Promise.reject(new Error(`Unsupported platform ${platform}`));
    }
  }
}

module.exports = Factorio;
