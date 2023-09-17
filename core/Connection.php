<?php
class Connection
{
    private static $instance = null;
    private function __construct()
    {
        // ket noi csdl
    }

    public static function getInstance()
    {
        if (self::$instance == null) {
            self::$instance = new Connection();
        }

        return self::$instance;
    }
}