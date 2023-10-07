<?php
    class ProjectLogModel extends Model{
        protected $__table = 'project_logs';
        public function GetLogs($pId){
            // $params = ['p_id'=>$pId];            
            // return $this->__db->executeStoredProcedure("ProjectLogs",$params);
            $columns = " content,DATE_FORMAT(timestamp, '%d/%m/%Y %H:%i:%s') as timestamp ";
            $where = " project_id = $pId";
            $orderby = " timestamp DESC";
            return $this->__db->select($this->__table,$columns,'',$where,[],1,0, $orderby);
        }
    }