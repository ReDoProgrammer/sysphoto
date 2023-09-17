<?php
    class Home{
        public function index(){
            echo 'home index';
        }

        public function detail($id='',$slug=''){
            echo $id.'---'.$slug;
        }

        public function search(){
            $keyword = $_GET['keyword'];
            echo 'tu khoa can tim: '.$keyword;
        }
    }