<?php
    $routes['default_controller'] = 'home';// controller mac dinh

    /**
     * Đường dẫn ảo => Đường dẫn thật
     */
    $routes['admin/login'] = 'admin/employee/login';
    // $routes['admin'] = 'admin/dashboard';
    $routes['admin/home'] = 'admin/dashboard';
    $routes['admin/du-an'] = 'admin/project';



    $routes['trang-chu'] = 'home';
    $routes['tin-tuc/(.+)'] = 'news/category/$1';
    $routes['tin-tuc/.+-(\d+).html'] = 'news/category/$1';
