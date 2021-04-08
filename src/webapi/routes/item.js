const { response } = require('express');

const Router = require('express-promise-router');
const { models } = require('../db/db');

const router = new Router();

module.exports = router;

router.get('/', async (req, res) => {
  const rows = await models.item.findAll();
  res.json(rows);
});