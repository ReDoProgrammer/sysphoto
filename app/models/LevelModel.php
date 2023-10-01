<?php
    class  LevelModel extends Model{
        protected $__table = 'level';
        public function getList(){           
           return $this->__db->select($this->__table);           
        }
    }