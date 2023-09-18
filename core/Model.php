<?php
/**
 * Base model
 * 
 */
class Model extends Database{
    protected $__db;
    function __construct(){
        $this->__db = new Database();
    }
}