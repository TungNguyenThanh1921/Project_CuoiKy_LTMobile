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

// Endpoint handler
app.get('/data', async (req, res) => {
  try {
    const chatSamples = ['Xin Chao!', 'Hello', 'Hi Guy!'];
    res.json({ chat_samples: chatSamples });
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).json({ error: 'Error fetching data' });
    console.log('Lỗi khi gửi yêu cầu API');
  }
});

const server = app.listen(8080, () => {
  console.log('HTTP server is running on port 8080');
});
