const items = require('./item')

module.exports = app => {
  app.use('/items', items)
}