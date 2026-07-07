const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  user: process.env.POSTGRES_USER || "aura_user",
  host: process.env.POSTGRES_HOST || "localhost",
  database: process.env.POSTGRES_DB || "aura_ai",
  password: process.env.POSTGRES_PASSWORD || "aura_password",
  port: process.env.POSTGRES_PORT || 5432,
});

module.exports = pool;