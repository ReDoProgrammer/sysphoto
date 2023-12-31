<?php
class App
{
    private $__controller, $__action, $__params, $__routes;
    function __construct()
    {
        // thiet lap mac dinh cho cac bien
        global $routes; // goi bien toan cuc $routes trong file configs/routes.php

        $this->__routes = new Route();
        if (!empty($routes['default_controller'])) {
            $this->__controller = $routes['default_controller'];
        }

        $this->__action = 'index';
        $this->__params = [];

        $this->handleUrl();
    }

    function getUrl()
    {
        if (!empty($_SERVER['PATH_INFO'])) {
            $url = $_SERVER['PATH_INFO'];
        } else {
            $url = '/';
        }
        return $url;
    }

    public function handleUrl()
    {
        $url = $this->getUrl();

        $url = $this->__routes->handleRoute($url);


        $urlArr = array_filter(explode('/', $url)); // tach chuoi tu duong dan
        $urlArr = array_values($urlArr); // dua ve dung chi so mang bat dau tu 0


        //xử lý các khu vực khác nhau: ví dụ: admin/home/index
        $urlCheck = '';
        if (!empty($urlArr)) {
            foreach ($urlArr as $key => $item) {
                $urlCheck .= $item . '/';
                $fileCheck = rtrim($urlCheck, '/');
                $fileArr = explode('/', $fileCheck);

                $fileArr[count($fileArr) - 1] = ucfirst($fileArr[count($fileArr) - 1]);

                $fileCheck = implode('/', $fileArr);
                if (!empty($urlArr[$key - 1])) {
                    unset($urlArr[$key - 1]);
                }
                if (file_exists('app/controllers/' . $fileCheck . '.php')) {
                    $urlCheck = $fileCheck;
                    break;
                }
            }
            $urlArr = array_values($urlArr);
        }


     


        // echo '<pre>';
        // print_r($urlArr);
        // print_r($urlCheck);
        // echo '</pre>';


        // xử lý controller
        if (!empty($urlArr[0])) {
            $this->__controller = ucfirst($urlArr[0]); // gan controller, viet hoa chu cai dau tien
        } else {
            $this->__controller = ucfirst($this->__controller);
        }

        //xử lý khi $urlCheck rỗng
        if(empty($urlCheck)){
            $urlCheck = $this->__controller;
        }

        if (file_exists('app/controllers/' . $urlCheck . '.php')) {
            require_once 'controllers/' . $urlCheck . '.php';

            //kiểm tra tồn tại của class $this->__controller
            if (class_exists($this->__controller)) {
                $this->__controller = new $this->__controller(); // khoi tao class
                unset($urlArr[0]);
            } else {
                $this->loadError();
            }

        } else {
            $this->loadError(404);
        }
        // xử lý action
        if (!empty($urlArr[1])) {
            $this->__action = $urlArr[1];
            unset($urlArr[1]);
        }

        //xử lý params
        $this->__params = array_values($urlArr);


        //kiểm tra tồn tại của action trong controller
        if (method_exists($this->__controller, $this->__action)) {
            call_user_func_array([$this->__controller, $this->__action], $this->__params);
        } else {
            $this->loadError(404);
        }


        // echo '<pre>';
        // print_r($this->__params);
        // echo '</pre>';

    }

    public function loadError($name = '404')
    {
        require_once 'errors/' . $name . '.php';
    }
}