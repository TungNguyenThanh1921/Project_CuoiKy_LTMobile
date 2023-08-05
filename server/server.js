// Phần WebSocket
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 9090 });


function broadcastUpdateConversation() {
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send('update-conversation');
    }
  });
}



wss.on('connection', (ws) => {
  console.log('A client connected.');

  ws.on('message', (message) => {
    console.log('New message received:', message);

      try {
      const data = JSON.parse(message);
      const roomId = data.roomId;
      const type = data.type;
      const content = data.content;
      console.log(roomId);
      console.log(type);
      console.log(content);

wss.clients.forEach((client) => {
    if (client !== ws && client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });

    } catch (error) {
      console.error('Error parsing JSON:', error);
    }
  });

  ws.on('close', () => {
    console.log('A client disconnected.');
  });
});


wss.on('listening', () => {
  const { address, port } = wss.address();
  console.log(`WebSocket server is running on ${address}:${port}`);
});



// Phần HTTP
const express = require('express');
const app = express();
const http = require('http').createServer(app);
const bodyParser = require('body-parser'); 
const io = require('socket.io')(http);
const { connectDB, queryDB } = require('./database');
let pool = null; 
// Middleware để kết nối cơ sở dữ liệu trước khi xử lý yêu cầu
app.use((req, res, next) => {
  if (!pool) {
    connectDB();
  }
  next();
});
app.use(express.json({ limit: '10mb' })); // Set the limit to 10 megabytes or adjust as needed
app.use(express.urlencoded({ limit: '10mb', extended: true })); // Set the limit to 10 megabytes or adjust as needed
const mssql = require('mssql');
// API endpoint to update user's avatar
app.post('/updateAvatar', async (req, res) => {
  try {
    console.log('Request Body:', req.body); 
    const { email, avatar } = req.body;

    // Update the user's avatar in the database based on the provided email
    const sqlStatement = `UPDATE Users SET avatar = '${avatar}' WHERE email = '${email}'`;
    
    // Assuming you have a function in your 'database' module to execute the SQL statement
    await queryDB(sqlStatement);

    // Return a success response upon successful update
    res.status(200).json({ message: 'Avatar updated successfully' });
  } catch (error) {
    console.error('Error updating avatar:', error);
    res.status(500).json({ error: 'Error updating avatar' });
  }
});

app.post('/updateImageMesseges', async (req, res) => {
  try {
    console.log('Request Body:', req.body);
    const { userId, type, roomId, content } = req.body;

    // Create a SQL query with named parameters
    const sqlStatement = 'INSERT INTO Message (conversation_id, sender_user_id, content, img) VALUES (@roomId, @userId, NULL, @content)';
    const pool = await mssql.connect({
      user: 'sa',
      password: 'sa',
      server: 'MSI',
      database: 'ChatApp',
    });

    // Define the named parameters
    const request = pool.request();
    request.input('roomId', mssql.Int, roomId);
    request.input('userId', mssql.Int, userId);
    request.input('content', mssql.VarChar, content);

    // Execute the query
    const result = await request.query(sqlStatement);

    // Return a success response upon successful update
    res.status(200).json({ message: 'Message inserted successfully' });
  } catch (error) {
    console.error('Error inserting message:', error);
    res.status(500).json({ error: 'Error inserting message' });
  }
});


// Endpoint handler nhận call api từ app và lấy dữ liệu
app.get('/data', async (req, res) => {
  try {
    const sqlStatement = req.query.sql;

    // Thực thi câu lệnh SQL để lấy dữ liệu từ cơ sở dữ liệu
    const result = await queryDB(sqlStatement);
    // Thực hiện các truy vấn lấy dữ liệu từ cơ sở dữ liệu
   
	console.log(result);
    const dataUser = result.map((row) => row.userna);
    res.json({ chat_samples: chatSamples });
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).json({ error: 'Error fetching data' });
    console.log('loi gui api');
  }
});

app.get('/updateConversation', async (req, res) => {
  try {
    // Trích xuất câu lệnh SQL từ tham số 'sql' trong URL
    const sqlStatement = req.query.sql;

    // Thực thi câu lệnh SQL để lấy dữ liệu từ cơ sở dữ liệu
    const result = await queryDB(sqlStatement);

    // Gửi dữ liệu trả về cho client dưới dạng JSON
    res.json(result);
	  broadcastUpdateConversation();
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).json({ error: 'Error fetching data' });
  }
});

app.get('/GetData', async (req, res) => {
  try {
    // Trích xuất câu lệnh SQL từ tham số 'sql' trong URL
    const sqlStatement = req.query.sql;

    // Thực thi câu lệnh SQL để lấy dữ liệu từ cơ sở dữ liệu
    const result = await queryDB(sqlStatement);

    // Gửi dữ liệu trả về cho client dưới dạng JSON
    res.json(result);
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).json({ error: 'Error fetching data' });
  }
});

app.get('/CheckLogin', async (req, res) => {
  try {
    // Trích xuất câu lệnh SQL từ tham số 'sql' trong URL
    const sqlStatement = req.query.sql;

    // Thực thi câu lệnh SQL để lấy dữ liệu từ cơ sở dữ liệu
    const result = await queryDB(sqlStatement);

    // Gửi dữ liệu trả về cho client dưới dạng JSON
    res.json(result);
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).json({ error: 'Error fetching data' });
  }
});

app.get('/products', async (req, res) => {
  try {
    // Thực hiện các truy vấn lấy dữ liệu từ cơ sở dữ liệu
    const result = await queryDB('SELECT * FROM PRODUCT');
    res.json(result);
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).json({ error: 'Error fetching data' });
  }
});


app.get('/getIP', (req, res) => {
  const ipAddress = req.ip;
  res.json({ ip_address: ipAddress });
	console.log(ipAddress)
});


const server = app.listen(8080, () => {
  console.log('HTTP server is running on port 8080');
});


