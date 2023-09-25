<?php
    $routes['default_controller'] = 'home';// controller mac dinh

    /**
     * Đường dẫn ảo => Đường dẫn thật
     */
    $routes['admin/login'] = 'admin/employee/login';
    $routes['admin/home'] = 'admin/dashboard';

    $routes['cong-viec'] = 'job';
    $routes['nhiem-vu'] = 'task';
    $routes['trang-chu'] = 'home';
    $routes['tin-tuc/(.+)'] = 'news/category/$1';
    $routes['tin-tuc/.+-(\d+).html'] = 'news/category/$1';
