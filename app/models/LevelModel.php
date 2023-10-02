<?php
    class  LevelModel extends Model{
        protected $__table = 'levels';
        public function getList(){           
           return $this->__db->select($this->__table);           
        }
    }