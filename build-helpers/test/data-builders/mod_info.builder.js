const faker       = require('faker');
const { toLower } = require('lodash');

const mod_name_from_title = (title) =>
{
  return toLower(title)
    .split(' ')
    .join('-');
};

const random_name  = () =>
{
  const first_name = faker.name.firstName();
  const last_name = faker.name.lastName();

  return `${first_name} ${last_name}`;
};

const generate_random_info = () =>
{
  const title = faker.name.title();

  return {
    name:             mod_name_from_title(title),
    version:          faker.system.semver(),
    title,
    author:           random_name(),
    factorio_version: '1.1',
    description:      faker.lorem.sentences()
  };
};

module.exports = { generate_random_info };
