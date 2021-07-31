const fs               = require('fs/promises');
const { constants }    = require('fs');
const path             = require('path');
const chai             = require('chai');
const chai_as_promised = require('chai-as-promised');
const unzipit          = require('unzipit');

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

    let scenario;

    beforeEach(function ()
    {
      return build_scenario()
        .then(new_scenario =>
        {
          scenario = new_scenario;

          const { mod_info } = scenario;
          const expected_zip_name = `${mod_info.name}_${mod_info.version}.zip`;
          const expected_zip_path = path.join(scenario.destination_folder.path, expected_zip_name);

          scenario.expected_zip_name = expected_zip_name;
          scenario.expected_zip_path = expected_zip_path;
          scenario.expected_zip_content_count = 7;
        });
    });

    it('must generate zip file with the correct name inside destination folder', function ()
    {
      return build_mod(scenario.source_folder.path, scenario.destination_folder.path)
        .then(() => expect(fs.access(scenario.expected_zip_path, constants.R_OK)).to.eventually.be.fulfilled);
    });

    it('zip root must be the mod folder', function ()
    {
      return build_mod(scenario.source_folder.path, scenario.destination_folder.path)
        .then(() => fs.readFile(scenario.expected_zip_path))
        .then(zip_buffer => unzipit.unzip(new Uint8Array(zip_buffer)))
        .then(({ entries }) => Object.keys(entries))
        .then(zip_files =>
        {
          expect(zip_files).to.have.length(scenario.expected_zip_content_count);

          const root_folder = path.parse(zip_files[0]).base;
          const expected_folder = path.parse(scenario.source_folder.path).base;

          expect(root_folder).to.be.equal(expected_folder);
        });
    });

    it('the contents must match mod contents', function ()
    {
      let mod_files;

      return build_mod(scenario.source_folder.path, scenario.destination_folder.path)
        .then(() => fs.readFile(scenario.expected_zip_path))
        .then(zip_buffer => unzipit.unzip(new Uint8Array(zip_buffer)))
        .then(({ entries }) => Object.keys(entries))
        .then(zip_files => path.join('/tmp', zip_files[0]))
        .then(fs.readdir)
        .then(files => (mod_files = files))
        .then(() => fs.readdir(scenario.source_folder.path))
        .then(source_files =>
        {
          source_files.forEach((source_file, i) =>
          {
            expect(source_file).to.be.equal(mod_files[i]);
          });
        });
    });
  });
});
