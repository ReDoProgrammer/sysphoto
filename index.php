<?php 
   if(!empty($_SERVER['PATH_INFO'])){
        $url = $_SERVER['PATH_INFO'];
   }else{
    $url ='/';
   }
   echo $url;