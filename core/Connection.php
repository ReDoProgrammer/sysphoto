<?php
class Connection
{
    private static $instance = null,$conn = null;
    private function __construct($config){
        try {
           $dsn = 'mysql:dbname='.$config['db'].';host='.$config['host'];

           /**
            * Cấu hình options
            * - UFT-8
            * - Cấu hình ngoại lệ khi truy vấn bị lỗi
            */
            $options = [
                PDO::MYSQL_ATTR_INIT_COMMAND=>'SET NAMES utf8',
                PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION
            ];

            //kết nối csdl
            self::$conn = new PDO($dsn,$config['user'],$config['password'],$options);
            
        } catch (PDOException $e) {
            echo "Lỗi kết nối cơ sở dữ liệu: " . $e->getMessage();
            die();
        }
    }
    public static function getInstance($db_config)
    {
        if (self::$instance == null) {
            new Connection($db_config);
            self::$instance = self::$conn;
        }

        return self::$instance;
    }
}