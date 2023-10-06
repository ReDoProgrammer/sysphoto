<?php
    class  CloudModel extends Model{
        protected $__table = 'clouds';
        public function AllClouds(){          
            return $this->__db->select($this->__table,"id,name");
        }
    }