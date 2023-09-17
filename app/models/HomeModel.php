<?php
/**
 * kế thừa từ class Model
 */
    class HomeModel{
        protected $table = 'products';
        public function getProductList(){
            $data = [
                'Item 1',
                'Item 2',
                'Item 3',
                'Item 4',
                'Item 5'
            ];
            return $data;
        }
        public function getDetail($id){
            $data = [
                'Item 1',
                'Item 2',
                'Item 3',
                'Item 4',
                'Item 5'
            ];
            return $data[$id];
        }
    }