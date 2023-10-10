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
        public function DeleteCC($id){
            $user = unserialize($_SESSION['user']);   
            $params = [
                        'p_id'=>$id,
                        'p_deleted_by'=>$user->acronym
                    ];
            return $this->__db->executeStoredProcedure("CCDelete",$params);
        }
        public function AllCCs($project_id){
            $columns = "id,feedback,DATE_FORMAT(start_date, '%d/%m/%Y %H:%i') as start_date,DATE_FORMAT(end_date, '%d/%m/%Y %H:%i') as end_date";
            return $this->__db->select($this->__table,$columns,"","project_id = $project_id");
        }

        public function GetCCsListWithTasks($p_project){
        //    $columns = " c.id AS id, c.feedback,";
        //    $columns.="  IF( COUNT(t.id) > 0,
        //                     CONCAT('[', GROUP_CONCAT(
        //                         JSON_OBJECT(
        //                             'task_id', t.id,
        //                             'level_id', lv.name,
        //                             'quantity', t.quantity,
        //                             'editor', e.acronym,
        //                             'qa', q.acronym,
        //                             'dc', dc.acronym,
        //                             'status', ts.name,
        //                             'status_color', ts.color
        //                         ) SEPARATOR ','
        //                     ), ']'),
        //                     '[]'
        //                 ) AS tasks_list";
        //     $join = "LEFT JOIN tasks t ON c.id = t.cc_id";
        //     $join .="LEFT JOIN levels lv ON t.level_id = lv.id";
        //     $join .="LEFT JOIN users e ON t.editor_id = e.id";
        //     $join .="LEFT JOIN users q ON t.qa_id = q.id";
        //     $join .="LEFT JOIN users dc ON t.dc_id = dc.id";
        //     $join .="LEFT JOIN task_statuses ts ON t.status_id = ts.id";
        //     $where = "c.project_id = $prjId";
        //     $groupby = " c.id, c.project_id;";
        //     return $this->__db->select($this->__table." c", $columns, $join, $where,[],1,0,'', $groupby);
        
        $params = [$p_project];
        return $this->__db->callStoredProcedure("PrjectGetCCsWithTasks",$params);
        }
    }