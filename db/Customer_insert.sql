DELIMITER //
CREATE PROCEDURE CustomerInsert(
    IN p_group_id INT,IN p_name varchar(100),IN p_email varchar(255),IN p_password varchar(255),IN p_customer_url varchar(255),
    IN p_color_mode INT, IN p_output INT, IN p_size varchar(255), IN p_is_straighten BOOLEAN, IN p_straighten_remark varchar(255),
    IN p_tv VARCHAR(255), IN p_fire VARCHAR(255),IN p_sky varchar(255), IN p_grass varchar(255),IN p_national_style INT, IN p_cloud INT,
    IN p_style_remark text,IN p_created_by INT
)
BEGIN
    DECLARE v_acronym VARCHAR(100) DEFAULT '';
    SET v_acronym = GetInitials(p_name);
	INSERT INTO customers(group_id,name,acronym,email,pwd,customer_url,color_mode_id,output_id,size,is_straighten,straighten_remark,tv,fire,sky,grass,national_style_id,cloud_id,style_remark,created_by)
    VALUES(p_group_id,p_name,v_acronym,p_email,md5(p_password),p_customer_url,p_color_mode,p_output,p_size,p_is_straighten,p_straighten_remark,p_tv,p_fire,p_sky,p_grass,p_national_style,p_cloud,p_style_remark,p_created_by);
END; //