-- 1. Khởi tạo Database
DROP DATABASE IF EXISTS social_media;
CREATE DATABASE social_media;
USE social_media;

-- 2. Tạo bảng Users
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tạo bảng Posts
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 4. Tạo bảng Comments
CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 5. Tạo bảng Friends
CREATE TABLE Friends (
    user_id INT,
    friend_id INT,
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted')),
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 6. Tạo bảng Likes
CREATE TABLE Likes (
    user_id INT,
    post_id INT,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE
);

---------------------------------------------------------
-- INSERT DỮ LIỆU (ĐÃ SỬA LỖI KHÓA NGOẠI)
---------------------------------------------------------

-- Thêm 10 Users (ID từ 1 đến 10)
INSERT INTO Users (username, password, email, created_at) VALUES 
('hoang_long', 'pass123', 'long@example.com', '2026-01-01 08:00:00'),
('minh_thu', 'pass123', 'thu@example.com', '2026-01-05 09:30:00'),
('anh_tuan', 'pass123', 'tuan@example.com', '2026-01-10 10:15:00'),
('bao_ngoc', 'pass123', 'ngoc@example.com', '2026-01-15 11:00:00'),
('gia_huy', 'pass123', 'huy@example.com', '2026-01-18 14:20:00'),
('thanh_mai', 'pass123', 'mai@example.com', '2026-01-20 16:45:00'),
('quoc_anh', 'pass123', 'quoc@example.com', '2026-01-21 17:00:00'),
('thuy_tien', 'pass123', 'tien@example.com', '2026-01-22 19:30:00'),
('duc_thinh', 'pass123', 'thinh@example.com', '2026-01-23 20:10:00'),
('khanh_huyen', 'pass123', 'huyen@example.com', '2026-01-24 21:00:00');

-- Thêm 10 Posts (ID từ 1 đến 10)
INSERT INTO Posts (user_id, content, created_at) VALUES 
(1, 'Học SQL thật thú vị!', '2026-01-02 10:00:00'),
(2, 'Chào buổi sáng cả nhà!', '2026-01-18 07:00:00'),
(3, 'Review phim mới ra rạp hôm nay.', '2026-01-20 20:00:00'),
(4, 'Có ai đang code xuyên đêm không?', '2026-01-21 02:00:00'),
(5, 'Thời tiết Hà Nội hôm nay lạ quá.', '2026-01-22 15:00:00'),
(6, 'Database là trái tim của ứng dụng.', '2026-01-23 09:00:00'),
(7, 'Vừa hoàn thành xong mini project!', '2026-01-24 16:00:00'),
(8, 'Tìm đồng đội học nhóm SQL nâng cao.', '2026-01-25 10:00:00'),
(9, 'Ai rảnh đi cafe Highland không?', '2026-01-25 14:00:00'),
(10, 'Chúc mừng năm mới 2026!', '2026-01-01 00:00:01');

-- Thêm 10 Comments (Sửa user_id 11, 12, 13 về phạm vi 1-10)
INSERT INTO Comments (post_id, user_id, content) VALUES 
(4, 6, 'Đúng rồi, mình cũng thấy vậy!'),
(4, 7, 'Share tài liệu học với bạn ơi.'),
(5, 8, 'Phim này đoạn kết hơi hụt hẫng.'),
(6, 9, 'Đang sấp mặt đây bạn ơi...'),
(7, 1, 'Sáng nắng chiều mưa đúng không?'),
(8, 5, 'Quá chuẩn luôn thầy ơi!'),
(9, 6, 'Chúc mừng nhé, giỏi quá.'),
(1, 7, 'Cho mình đăng ký 1 slot với.'),
(9, 8, 'Hết bàn rồi bạn ơi, đông lắm.'),
(4, 1, 'SQL là chân ái!');

-- Thêm 10 Likes
INSERT INTO Likes (user_id, post_id) VALUES 
(1, 4), (2, 4), (3, 4), 
(4, 5), (5, 5), 
(6, 6), (7, 6), 
(8, 7), 
(9, 8), 
(10, 9);

-- Thêm 10 Friends (Chỉ sử dụng user_id từ 1 đến 10)
INSERT INTO Friends (user_id, friend_id, status) VALUES 
(1, 2, 'accepted'),
(1, 3, 'accepted'),
(2, 4, 'pending'),
(3, 5, 'accepted'),
(4, 6, 'accepted'),
(5, 1, 'pending'),
(6, 7, 'accepted'),
(7, 8, 'accepted'),
(8, 9, 'pending'),
(9, 10, 'accepted');