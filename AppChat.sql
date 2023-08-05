create database ChatApp
Use ChatApp;

-- T?o b?ng Ng??i d�ng (Users)
CREATE TABLE Users (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    avatar VARCHAR(MAX),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- T?o b?ng Cu?c tr� chuy?n (Conversation)
CREATE TABLE Conversation (
    conversation_id INT PRIMARY KEY IDENTITY(1,1),
    conversation_name VARCHAR(100),
    user_id INT,
    participant_id INT, -- Th�m c?t ?? l?u tr? th�ng tin ng??i tham gia cu?c tr� chuy?n ri�ng t?
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsPrivate BIT NOT NULL DEFAULT 0, -- Th�m tr??ng IsPrivate ?? x�c ??nh cu?c tr� chuy?n c� ri�ng t? hay kh�ng
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (participant_id) REFERENCES Users(user_id) -- Th�m kh�a ngo?i ?? li�n k?t v?i b?ng Users
);

CREATE TABLE Message  (
    message_id INT PRIMARY KEY IDENTITY(1,1),
    conversation_id INT,
    sender_user_id INT,
    content TEXT,
    img VARCHAR(MAX),
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES Conversation(conversation_id),
    FOREIGN KEY (sender_user_id) REFERENCES Users(user_id)
);
INSERT INTO Users (username, email, password, avatar, created_at)
VALUES
    (N'??t', 'DAT.doe@email.com', 'abc123', NULL, '2023-07-28 10:00:00'),
    ('Trang', 'Trang123@email.com', 'abc456', NULL, '2023-07-28 11:30:00'),
    (N'T�i', 'TTTai@email.com', 'abc789', NULL, '2023-07-28 12:15:00');

	INSERT INTO Conversation (conversation_name, user_id, participant_id, created_at, IsPrivate)
VALUES
    ('General Chat', 1, null, '2023-07-28 10:00:00', 0),
    ('Private Chat 1', 2,1, '2023-07-28 11:30:00', 1),
    ('Public Chat 1', 3, null,'2023-07-28 12:15:00', 0);

	INSERT INTO Message (conversation_id, sender_user_id, content, img, sent_at)
VALUES
    (1, 1, 'Hello, everyone!', NULL, '2023-07-28 10:05:00'),
    (1, 2, 'hehehe!', NULL, '2023-07-28 10:10:00'),
    (2, 2, 'private message.', NULL, '2023-07-28 11:35:00'),
    (2, 1, 'xin chao', NULL, '2023-07-28 11:40:00'),
    (3, 3, 'Hello, world!', NULL, '2023-07-28 12:20:00');

select * from Message
select * from Users
select * from Conversation