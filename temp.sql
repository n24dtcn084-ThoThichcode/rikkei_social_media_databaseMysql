
drop procedure if exists sp_send_friend_request;
drop procedure if exists sp_accept_friend;
drop procedure if exists sp_delete_friendship;
drop procedure if exists sp_delete_post;

drop trigger if exists tg_after_accept_friend;
drop trigger if exists tg_before_delete_post;

DELIMITER //
-- gửi yêu cầu kết bạn
CREATE PROCEDURE sp_send_friend_request(IN p_sender_id INT, IN p_receiver_id INT)
BEGIN
    IF p_sender_id = p_receiver_id THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Không thể gửi yêu cầu kết bạn cho chính mình';
    END IF;
    IF EXISTS (
        SELECT 1 FROM friends 
        WHERE (user_id = p_sender_id AND friend_id = p_receiver_id) 
           OR (user_id = p_receiver_id AND friend_id = p_sender_id)
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Yêu cầu đã tồn tại hoặc hai người đã là bạn';
    END IF;
    -- Thực hiện INSERT nếu hợp lệ
    INSERT INTO friends (user_id, friend_id, status)
    VALUES (p_sender_id, p_receiver_id, 'pending');
    SELECT 'Gửi yêu cầu kết bạn thành công!' AS result;
END //
DELIMITER ;

-- chấp nhận lời mời kết bạn
delimiter //
create trigger tg_after_accept_friend
after update on friends
for each row
begin
	if old.status = 'pending' and new.status = 'accepted' then
		if not exists (select 1 from friends where user_id = new.friend_id and friend_id = new.user_id) then
			insert into friends (user_id, friend_id, status)
            values (new.friend_id, old.user_id, 'accepted');
		else
			-- tồn tại rồi thì cập nhập
            update friends set status = 'accepted'
            where user_id = new.friend_id and friend_id = new.user_id;
		end if;
    end if;
end
// delimiter ;

-- accept friend chấp nhận lời mời kết bạn
delimiter //
create procedure sp_accept_friend (in p_user_id int, in p_friend_id int)
begin
	UPDATE friends 
    SET status = 'accepted' 
    WHERE user_id = p_sender_id AND friend_id = p_user_id AND status = 'pending';
    
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'có lời mời kết bạn nào đâu mà chấp nhận!';
    END IF;
end
// delimiter ;




-- bai 6 xoa và cập nhập transaction sp_delete_friendship
delimiter //
create procedure sp_delete_friendship(in p_user_id1 int, in p_user_id2 int)
begin
	declare exit handler for sqlexception
    begin
		rollback;
        signal sqlstate '45000' set message_text = 'lỗi mợ nó rồi ae ạ';
    end;
    start transaction;
		delete from friends where  (user_id = p_user_id1 and friend_id = p_user_id2) 
								or (user_id = p_user_id2 and friend_id = p_user_id1);
	commit;
    select 'huy ket ban roi baby';
end
// delimiter  ;

-- bài 7 xoá bài viết

delimiter //
create trigger tg_before_delete_post
before delete on posts
for each row
begin
	-- xoa tất cả lượt comment của bài viết
    delete from comments where post_id = old.post_id;
    
    -- xoá tất cả lượt like của bài viết
    delete from likes where post_id = old.post_id;
end
// delimiter ;


delimiter //
create procedure sp_delete_post(in p_post_id int, in p_user_id int)
begin
	declare owner_post_id int;
	declare exit handler for sqlexception
    begin
		rollback;
        signal sqlstate '45000' set message_text = 'loi roi không xoá được';
    end;
    
    select user_id into owner_post_id from posts where post_id = p_post_id;
    
    if owner_post_id is null then
		signal sqlstate '45000' set message_text = 'đâu có bài viết nào';
	elseif owner_post_id <> p_user_id then
		signal sqlstate '45000' set message_text = 'đâu phải chủ bài viết đâu mà xoá';
    else
		start transaction;
			
            delete from posts where post_id = p_post_id;
		
        commit;
	end if;
end// 
delimiter ;





