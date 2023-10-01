<?php
    class  TaskStatusModel extends Model{
        protected $__table = 'status_task';
        public function getList(){      
            $orderby = " id DESC";      
            $data = $this->__db->select($this->__table,"*","","",[],1,0,$orderby);
            return $data;
        }
    }