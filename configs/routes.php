<?php
    $routes['default_controller'] = 'home';// controller mac dinh

    /**
     * Đường dẫn ảo => Đường dẫn thật
     */
    $routes['admin/login'] = 'admin/auth/login';


    $routes['editor/login']='editor/auth/login';


    $routes['trang-chu'] = 'home';
    $routes['tin-tuc/(.+)'] = 'news/category/$1';
    $routes['tin-tuc/.+-(\d+).html'] = 'news/category/$1';
