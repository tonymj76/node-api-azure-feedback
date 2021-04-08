const { Sequelize } = require('sequelize');
const secrets = require('../secrets');

const db = new Sequelize(
  secrets.get('PGDB'),
  secrets.get('PGUSER'),
  secrets.get('PGPASSWORD'),
  {
    dialect: 'postgres',
    host: process.env.PGHOST
  });

const modelDefiners = [
  require('../models/item')
];

for (const modelDefiner of modelDefiners) {
  modelDefiner(db);
}

module.exports = db;