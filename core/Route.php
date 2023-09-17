<?php
    class Route{

        function handleRoute($url){
            global $routes;
            unset($routes['default_controller']);// loai default_controller
            
            
            // echo '<pre>';
            // print_r($routes);
            // echo '</pre>';

            $url = trim($url,'/');
            $handleUrl = $url;
            if(!empty($routes)){
                foreach($routes as $key=>$value){
                    if(preg_match('~'.$key.'~is',$url)){
                        $handleUrl = preg_replace('~'.$key.'~',$value,$url);
                    }
                }
            }          
            return $handleUrl;

        }
    }