// Phần WebSocket
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 9090 });

wss.on('connection', (ws) => {
  console.log('A client connected.');

  // Xử lý tin nhắn mới từ client
  ws.on('message', (message) => {
    console.log('New message:', message);

    // Broadcast tin nhắn mới tới tất cả các client khác
    wss.clients.forEach((client) => {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(message);
        console.log('Đã gửi tin nhắn cho các client khác');
        
      }
    });
  });

  // Xử lý sự kiện client đóng kết nối
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

// Endpoint handler nhận call api từ app và lấy dữ liệu
app.get('/data', async (req, res) => {
  try {
    // Thực hiện các truy vấn lấy dữ liệu từ cơ sở dữ liệu
    const result = await queryDB('SELECT * FROM PRODUCT');
    const chatSamples = result.map((row) => row.ProductName);
    res.json({ chat_samples: chatSamples });
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).json({ error: 'Error fetching data' });
    console.log('loi gui api');
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


