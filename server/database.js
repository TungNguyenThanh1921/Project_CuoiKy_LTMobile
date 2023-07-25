const sql = require('mssql');

const config = {
  user: 'sa',
  password: 'sa',
  server: 'MSI',
  database: 'SanPham',
  options: {
    enableArithAbort: true,
    encrypt: false,
  },
};

let pool = null;

async function connectDB() {
  try {
    if (!pool) {
      pool = await sql.connect(config);
      console.log('Connected to SQL Server');
    }
  } catch (error) {
    console.error('Error connecting to SQL Server:', error.message);
  }
}

async function queryDB(query) {
  try {
	if (!pool) {
      await connectDB(); // Kiểm tra và kết nối cơ sở dữ liệu nếu pool chưa được khởi tạo
    }
    const result = await pool.request().query(query);
    return result.recordset;
  } catch (error) {
    console.error('Error querying database:', error.message);
    throw error;
  }
}

module.exports = {
  connectDB,
  queryDB,
};
