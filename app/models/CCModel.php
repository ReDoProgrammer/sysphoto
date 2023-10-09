<?php
    class  CCModel extends Model{
        protected $__table = 'ccs';
        public function InsertCC($project_id,$feedback,$start_date,$end_date){     
            $user = unserialize($_SESSION['user']);     
            $params = [
                'p_project'=>$project_id,
                'p_feedback'=>$feedback,
                'p_start_date'=>$start_date,
                'p_end_date'=>$end_date,
                'p_created_by'=>$user->id
            ];
            return $this->__db->executeStoredProcedure("CCInsert",$params);
        }
        public function AllCCs($project_id){
            $columns = "id,feedback,DATE_FORMAT(start_date, '%d/%m/%Y %H:%i') as start_date,DATE_FORMAT(end_date, '%d/%m/%Y %H:%i') as end_date";
            return $this->__db->select($this->__table,$columns,"","project_id = $project_id");
        }
    }