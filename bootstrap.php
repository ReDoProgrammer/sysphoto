<?php
    define('__DIR_ROOT',__DIR__);

    //xử lý http root
    if(!empty($_SERVER['HTTPS']) && $_SERVER['HTTP_HOST'] =='on'){
        $web_root = 'https://'.$_SERVER['HTTP_HOST'];
    }else{
        $web_root = 'http://'.$_SERVER['HTTP_HOST'];
    }
  
    $dr = strtolower(str_replace('\\','/',__DIR_ROOT));

    $folder = str_replace(strtolower($_SERVER['DOCUMENT_ROOT']),'',$dr);
    $web_root .=$folder;
    define('_WEB_ROOT',$web_root);// đường dẫn project

    require_once 'configs/routes.php';
    require_once 'app/App.php';
    require_once 'core/Controller.php';// load basecontroller