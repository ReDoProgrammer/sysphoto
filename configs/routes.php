<?php
    $routes['default_controller'] = 'home';// controller mac dinh

    /**
     * Đường dẫn ảo => Đường dẫn thật
     */
    $routes['admin/login'] = 'admin/auth/login';
    $routes['admin/home'] = 'admin/dashboard';


    $routes['editor/login']='editor/auth/login';
    $routes['qa/login']='qa/auth/login';
    $routes['dc/login']='dc/auth/login';
    $routes['tla/login']='tla/auth/login';
    $routes['css/login']='css/auth/login';


    $routes['trang-chu'] = 'home';
    $routes['tin-tuc/(.+)'] = 'news/category/$1';
    $routes['tin-tuc/.+-(\d+).html'] = 'news/category/$1';
    