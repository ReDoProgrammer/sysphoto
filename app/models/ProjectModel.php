<?php
    class ProjectModel extends Model{
        protected $__table = 'project_list';
        public function getList(){
            $data = $this->__db->select($this->__table);
            return $data;
        }
    }