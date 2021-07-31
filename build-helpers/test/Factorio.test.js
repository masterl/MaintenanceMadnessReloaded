const path = require('path');
const chai = require('chai');
const os   = require('os');

const Factorio = require('../src/Factorio');

const { expect } = chai;

describe('class Factorio', function ()
{
  describe('get_mod_folder method', function ()
  {
    it('should return the correct path to Factorio mods folder', function ()
    {
      let expected_path;

      if (process.platform === 'linux')
      {
        expected_path = path.join(os.homedir(), '.factorio', 'mods');
      }
      // TODO: add expectation for Windows, etc

      return Factorio.get_mods_folder()
        .then(mods_folder => expect(mods_folder).to.be.equal(expected_path));
    });
  });
});
