<?php
    class  NationalStyleModel extends Model{
        protected $__table = 'national_styles';
        public function AllNationalStyle(){           
           return $this->__db->select($this->__table);           
        }
    }