<?php
    class  OutputModel extends Model{
        protected $__table = 'outputs';
        public function AllOutput(){           
           return $this->__db->select($this->__table);           
        }
    }