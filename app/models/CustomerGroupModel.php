<?php
    class  CustomerGroupModel extends Model{
        protected $__table = 'customer_groups';
        public function getList(){  
            return $this->__db->select($this->__table);
        }
     }