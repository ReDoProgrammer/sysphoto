<?php
    class  TaskStatusModel extends Model{
        protected $__table = 'status_task';
        public function getList(){            
            $data = $this->__db->select($this->__table);
            return $data;
        }
    }