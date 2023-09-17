<?php
    $routes['default_controller'] = 'home';// controller mac dinh

    /**
     * Đường dẫn ảo => Đường dẫn thật
     */
    $routes['san-pham'] = 'product/index';
    $routes['cong-viec'] = 'job';
    $routes['nhiem-vu'] = 'task';
    $routes['trang-chu'] = 'home';
    $routes['tin-tuc/(.+)'] = 'news/category/$1';
    $routes['tin-tuc/.+-(\d+).htmlq'] = 'news/category/$1';