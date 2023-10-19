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

    /**
     * tự động load configs
     */
    $configs_dir = scandir('configs');
    if(!empty($configs_dir)){
        foreach($configs_dir as $cf){
            if($cf !='.' && $cf !='..' && file_exists('configs/'.$cf)){
                require_once 'configs/'.$cf;
            }
        }
    }
    
    require_once 'core/Route.php';
    require_once 'app/App.php';
   


    if(!empty($config['database'])){
        $db_config = $config['database'];
        require_once 'core/Connection.php';
        require_once 'core/Database.php';       
    }
    require_once 'app/models/User.php';
    require_once 'core/Model.php';//load basemodel
    require_once 'core/Controller.php';// load basecontroller
    require_once 'core/AdminController.php';// load EditorController
    require_once 'core/EditorController.php';// load EditorController
    require_once 'core/QAController.php';// load QAController
    require_once 'core/DCController.php';// load DCController
    require_once 'core/TLAController.php';// load TLAController
    require_once 'core/Request.php';// load Request