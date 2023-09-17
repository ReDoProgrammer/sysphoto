<?php
/**
 * base controller
 */
class Controller
{
    public function model($model)
    {
        if (file_exists(__DIR_ROOT . '/app/models/' . $model . '.php')) {
            require_once __DIR_ROOT . '/app/models/' . $model . '.php';
            if(class_exists($model)){
                $model = new $model();
                return $model;
            }            
        }
        return false;

    }
}