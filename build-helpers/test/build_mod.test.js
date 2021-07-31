const fs               = require('fs/promises');
const { constants }      = require('fs');
const path             = require('path');
const chai             = require('chai');
const chai_as_promised = require('chai-as-promised');

chai.use(chai_as_promised);

const { expect } = chai;

const build_mod = require('../src/build_mod');

const { TmpDirBuilder, ModInfoBuilder } = require('./data-builders');

describe('function build_mod', function ()
{
  describe('Given valid mod source and destination folders', function ()
  {
    function build_scenario ()
    {
      const mod_info = ModInfoBuilder.generate_random_info();

      const scenario = { mod_info };

      return TmpDirBuilder.create_one_with_files(5)
        .then(dir_info => (scenario.source_folder = dir_info))
        .then(() => TmpDirBuilder.create_one_empty())
        .then(dir_info => (scenario.destination_folder = dir_info))
        .then(() => scenario.source_folder.create_file_inside('info.json', JSON.stringify(mod_info)))
        .then(() => scenario);
    }

    it('must generate zip file with the correct name inside destination folder', function ()
    {
      let scenario;
      return build_scenario()
        .then(test_scenario => (scenario = test_scenario))
        .then(() => build_mod(scenario.source_folder.path, scenario.destination_folder.path))
        .then(() =>
        {
          const { mod_info } = scenario;
          const expected_zip_name = `${mod_info.name}_${mod_info.version}.zip`;
          const expected_zip_path = path.join(scenario.destination_folder.path, expected_zip_name);

          return Promise.all([
            expect(fs.access(expected_zip_path, constants.R_OK)).to.eventually.be.fulfilled
          ]);
        });
    });
  });
});
