require('dotenv').config();
const sql = require('mssql');

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

console.log("Servidor configurado:", config.server);

sql.connect(config)
  .then(() => {
    console.log("Conectado a SQL Server correctamente");
  })
  .catch(err => {
    console.error("Error de conexión:", err);
  });

module.exports = { sql };