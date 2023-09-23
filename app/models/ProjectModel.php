<?php
    class ProjectModel extends Model{
        protected $__table = 'project_list';
        public function getList(){
            echo '13';
            $data = $this->__db->select($this->__table);
            return $data;
        }
    }