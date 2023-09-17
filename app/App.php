<?php
class App
{
    private $__controller, $__action, $__params;
    function __construct()
    {
        // thiet lap mac dinh cho cac bien
        global $routes;// goi bien toan cuc $routes trong file configs/routes.php
        if(!empty($routes['default_controller'])){
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

    public function handleUrl(){
        $url = $this->getUrl();
        $urlArr =array_filter( explode('/',$url));// tach chuoi tu duong dan
        $urlArr = array_values($urlArr);// dua ve dung chi so mang bat dau tu 0

        // xử lý controller
        if(!empty($urlArr[0])){
            $this->__controller = ucfirst($urlArr[0]);// gan controller, viet hoa chu cai dau tien
        }else{
            $this->__controller = ucfirst($this->__controller);
        }

        if(file_exists('app/controllers/'.$this->__controller.'.php')){
            require_once 'controllers/'.$this->__controller.'.php';
            $this->__controller = new $this->__controller();// khoi tao class
            unset($urlArr[0]);
        }else{
            $this->loadError(404);
        }
        // xử lý action
        if(!empty($urlArr[1])){
            $this->__action = $urlArr[1];
            unset($urlArr[1]);
        }

        //xử lý params
        $this->__params = array_values($urlArr);


        call_user_func_array([$this->__controller,$this->__action],$this->__params);

        // echo '<pre>';
        // print_r($this->__params);
        // echo '</pre>';

    }

    public function loadError($name = '404'){
            require_once 'errors/'.$name.'.php';
    }
}