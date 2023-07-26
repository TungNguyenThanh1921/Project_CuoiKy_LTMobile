create database ChatApp
Use ChatApp;

-- Tạo bảng Người dùng (Users)
CREATE TABLE Users (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    avatar VARBINARY(MAX),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tạo bảng Cuộc trò chuyện (Conversation)
CREATE TABLE Conversation (
    conversation_id INT PRIMARY KEY IDENTITY(1,1),
    conversation_name VARCHAR(100),
    user_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsPrivate BIT NOT NULL DEFAULT 0, -- Thêm trường IsPrivate để xác định cuộc trò chuyện có riêng tư hay không
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Message  (
    message_id INT PRIMARY KEY IDENTITY(1,1),
    conversation_id INT,
    sender_user_id INT,
    content TEXT,
    img VARBINARY(MAX),
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES Conversation(conversation_id),
    FOREIGN KEY (sender_user_id) REFERENCES Users(user_id)
);
