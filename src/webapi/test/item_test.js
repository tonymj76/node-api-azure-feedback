const chai = require('chai');
const should = require('chai').should();

const db = require('../db/db');

// Test that there's data in the database
describe('Get data from database using db.query', () => {
  it('it should return two rows', async () => {
    var results = await db.query('SELECT * FROM Items');
    // NOTE: results is actually [rows: [], metadata: object].
    results[0].length.should.be.equal(2);
  });
});

// Test that we get two items back from the webapi
const chaiHttp = require('chai-http');
const http = require('http');
chai.use(chaiHttp);

const App = require('../app');
const app = new App();
app.start();

const API = 'http://localhost:3000'

describe('HTTP call to /GET items', () => {
  it('it should GET all two items', (done) => {
    chai.request(API)
      .get('/items')
      .end((err, res) => {
        res.should.have.status(200);
        res.body.should.be.a('array');
        res.body.length.should.be.equal(2);
        done();
      });
  });
});