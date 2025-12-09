require('dotenv').config();
const sql = require('mssql');

const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

const poolPromise = new sql.ConnectionPool(dbConfig)
  .connect()
  .then(pool => {
    console.log('✅ Base de datos conectada');
    return pool;
  })
  .catch(err => {
    console.error('❌ Error de conexión con SQL Server:', err);
    return null;
  });

module.exports = {
  sql,
  poolPromise
};
