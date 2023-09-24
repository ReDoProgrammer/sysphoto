<?php
    class  JobStatusModel extends Model{
        protected $__table = 'status_job';
        public function getList(){           
            $data = $this->__db->select($this->__table);
            return $data;
        }
    }