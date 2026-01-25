-- cau 4
DELIMITER //
CREATE PROCEDURE sp_create_post(IN p_user_id INT, IN p_content TEXT)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE user_id = p_user_id) THEN
        INSERT INTO Posts (user_id, content) VALUES (p_user_id, p_content);
        SELECT 'Đăng bài thành công!' AS Message;
    ELSE
        SELECT 'Lỗi: Người dùng không tồn tại!' AS Message;
    END IF;
END //
DELIMITER ;

-- Gọi Procedure
CALL sp_create_post(1, 'Nội dung bài viết mới của tôi');

-- cau 5
CREATE VIEW vw_recent_posts AS
SELECT p.post_id, u.username, p.content, p.created_at
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
WHERE p.created_at >= NOW() - INTERVAL 7 DAY;

-- Truy vấn News Feed
SELECT * FROM vw_recent_posts ORDER BY created_at DESC;

-- cau 6
-- Tạo Index
CREATE INDEX idx_user_id ON Posts(user_id);
CREATE INDEX idx_user_created ON Posts(user_id, created_at DESC);

-- Truy vấn tối ưu
SELECT content, created_at FROM Posts 
WHERE user_id = 1 
ORDER BY created_at DESC;

-- cau 7
DELIMITER //
CREATE PROCEDURE sp_count_posts(IN p_user_id INT, OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total FROM Posts WHERE user_id = p_user_id;
END //
DELIMITER ;

-- Gọi và hiển thị
CALL sp_count_posts(1, @total);
SELECT @total AS TotalPosts;

-- cau 8
CREATE VIEW vw_active_users AS
SELECT * FROM Users
WHERE email IS NOT NULL AND email LIKE '%@%'
WITH CHECK OPTION;

-- Bài 9: Thêm bạn
DELIMITER //
CREATE PROCEDURE sp_add_friend(IN p_user_id INT, IN p_friend_id INT)
BEGIN
    IF p_user_id = p_friend_id THEN
        SELECT 'Không thể kết bạn với chính mình!' AS Message;
    ELSE
        INSERT INTO Friends (user_id, friend_id, status) VALUES (p_user_id, p_friend_id, 'pending');
    END IF;
END //
DELIMITER ;

-- Bài 10: Gợi ý bạn bè (Logic: Gợi ý những người chưa là bạn)
DELIMITER //
CREATE PROCEDURE sp_suggest_friends(IN p_user_id INT, INOUT p_limit INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    IF p_limit <= 0 THEN SET p_limit = 5; END IF; -- Mặc định gợi ý 5 người
    
    SELECT u.username FROM Users u 
    WHERE u.user_id <> p_user_id 
    AND u.user_id NOT IN (SELECT friend_id FROM Friends WHERE user_id = p_user_id)
    LIMIT p_limit;
END //
DELIMITER ;

-- cau 11
CREATE INDEX idx_likes_post_id ON Likes(post_id);
CREATE VIEW vw_top_posts AS
SELECT 
    p.post_id, 
    p.content, 
    u.username AS author,
    COUNT(l.user_id) AS total_likes
FROM Posts p
LEFT JOIN Likes l ON p.post_id = l.post_id
JOIN Users u ON p.user_id = u.user_id
GROUP BY p.post_id, p.content, u.username
ORDER BY total_likes DESC;

-- cau 12
DELIMITER //
CREATE PROCEDURE sp_add_comment(IN p_user_id INT, IN p_post_id INT, IN p_content TEXT)
BEGIN
    DECLARE user_exists INT;
    DECLARE post_exists INT;
    
    SELECT COUNT(*) INTO user_exists FROM Users WHERE user_id = p_user_id;
    SELECT COUNT(*) INTO post_exists FROM Posts WHERE post_id = p_post_id;
    
    IF user_exists > 0 AND post_exists > 0 THEN
        INSERT INTO Comments (user_id, post_id, content) VALUES (p_user_id, p_post_id, p_content);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User hoặc Post không tồn tại';
    END IF;
END //
DELIMITER ;

CREATE VIEW vw_post_comments AS
SELECT c.post_id, u.username, c.content, c.created_at
FROM Comments c
JOIN Users u ON c.user_id = u.user_id;

-- cau 13
DELIMITER //
CREATE PROCEDURE sp_like_post(IN p_user_id INT, IN p_post_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Likes WHERE user_id = p_user_id AND post_id = p_post_id) THEN
        INSERT INTO Likes (user_id, post_id) VALUES (p_user_id, p_post_id);
    END IF;
END //
DELIMITER ;

CREATE VIEW vw_post_likes AS
SELECT post_id, COUNT(*) AS total_likes FROM Likes GROUP BY post_id;

-- cau 14
DELIMITER //
CREATE PROCEDURE sp_search_social(IN p_option INT, IN p_keyword VARCHAR(100))
BEGIN
    IF p_option = 1 THEN
        SELECT * FROM Users WHERE username LIKE CONCAT('%', p_keyword, '%');
    ELSEIF p_option = 2 THEN
        SELECT * FROM Posts WHERE content LIKE CONCAT('%', p_keyword, '%');
    ELSE
        SELECT 'Lỗi: Tùy chọn không hợp lệ!' AS Message;
    END IF;
END //
DELIMITER ;

-- Test tìm kiếm
CALL sp_search_social(1, 'an');
CALL sp_search_social(2, 'database');