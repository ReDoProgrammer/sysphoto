<?php
    class  ProjectStatusModel extends Model{
        protected $__table = 'project_statuses';
        public function getList(){           
            $data = $this->__db->select($this->__table);
            return $data;
        }
    }