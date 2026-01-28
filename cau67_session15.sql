use social_media;

-- cau 6
DELIMITER //

CREATE PROCEDURE sp_update_friendship(
    IN p_user_id INT,
    IN p_friend_id INT,
    IN p_status VARCHAR(20), -- 'accepted', 'blocked', hoặc 'delete' để xóa
    IN p_action VARCHAR(10)  -- 'UPDATE' hoặc 'DELETE'
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi hệ thống, đã Rollback!';
    END;

    START TRANSACTION;
        IF p_action = 'DELETE' THEN
            -- Xóa cả hai chiều (nếu dữ liệu lưu 2 dòng) hoặc 1 dòng tùy logic
            DELETE FROM friends WHERE (user_id = p_user_id AND friend_id = p_friend_id);
            DELETE FROM friends WHERE (user_id = p_friend_id AND friend_id = p_user_id);
        ELSE
            -- Cập nhật trạng thái
            UPDATE friends SET status = p_status 
            WHERE (user_id = p_user_id AND friend_id = p_friend_id);
            
            UPDATE friends SET status = p_status 
            WHERE (user_id = p_friend_id AND friend_id = p_user_id);
        END IF;
    COMMIT;
END //

DELIMITER ;


-- cau 7
DELIMITER //

CREATE TRIGGER tg_before_delete_post
BEFORE DELETE ON posts
FOR EACH ROW
BEGIN
    -- Xóa tất cả likes liên quan đến bài viết
    DELETE FROM likes WHERE post_id = OLD.post_id;
    -- Xóa tất cả comments liên quan đến bài viết
    DELETE FROM comments WHERE post_id = OLD.post_id;
END //

DELIMITER ;

-- sp_delete_friendship xoá quan hệ friendship
DELIMITER //

CREATE PROCEDURE sp_delete_friendship(
    IN p_user_id_1 INT,
    IN p_user_id_2 INT
)
BEGIN
    -- Khai báo Handler để xử lý lỗi
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Nếu có lỗi, thu hồi lại toàn bộ thay đổi
        ROLLBACK;
        RESIGNAL SET MESSAGE_TEXT = 'Lỗi: Không thể xóa mối quan hệ. Đã Rollback giao dịch.';
    END;

    -- Bắt đầu Transaction
    START TRANSACTION;
        
        -- 1. Xóa chiều thuận: A kết bạn với B
        DELETE FROM friends 
        WHERE user_id = p_user_id_1 AND friend_id = p_user_id_2;
        
        -- 2. Xóa chiều nghịch: B kết bạn với A
        DELETE FROM friends 
        WHERE user_id = p_user_id_2 AND friend_id = p_user_id_1;

    -- Nếu cả 2 lệnh trên thành công, xác nhận thay đổi
    COMMIT;
    
    SELECT 'Xóa mối quan hệ bạn bè thành công!' AS result;
END //

DELIMITER ;