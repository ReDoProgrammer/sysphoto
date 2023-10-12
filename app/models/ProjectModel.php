<?php
    class ProjectModel extends Model{
        protected $__table = 'projects';

        public function CreateProject($customer,$name,$start_date,$end_date,$combo,$levels,$priority,$description){
            $user = unserialize($_SESSION['user']);
            $params = array(
                'p_customer_id' => $customer,
                'p_name' => $name,
                'p_start_date' => $start_date,
                'p_end_date' => $end_date,
                'p_combo_id' => $combo,
                'p_levels' => $levels,
                'p_priority' => $priority,
                'p_description' => $description,
                'p_created_by' => $user->id
            );
            return $this->__db->executeStoredProcedure("ProjectInsert",$params);
        }

        public function UpdateProject($id,$customer,$name,$start_date,$end_date,$combo,$levels,$priority,$description){
            $user = unserialize($_SESSION['user']);
            $params = array(
                'p_id'=>$id,
                'p_customer_id' => $customer,
                'p_name' => $name,
                'p_start_date' => $start_date,
                'p_end_date' => $end_date,
                'p_combo_id' => $combo,
                'p_levels' => $levels,
                'p_priority' => $priority,
                'p_description' => $description,
                'p_updated_by' => $user->id
            );
            return $this->__db->executeStoredProcedure("ProjectUpdate",$params);
        }

        public function DeleteProject($id){
            return $this->__db->delete($this->__table," id = $id");
        }

        public function ProjectDetail($id){
            $params = ['p_id'=>$id];
            return $this->__db->executeStoredProcedure("ProjectDetailJoin",$params);
        }

        public function GetList($from_date,$to_date,$stt,$search,$page = 1,$limit = 10){
            $columns = "p.id,c.acronym,p.name,p.status_id,
            DATE_FORMAT(p.start_date, '%d/%m/%Y %H:%i') start_date, DATE_FORMAT(p.end_date, '%d/%m/%Y %H:%i') end_date, 
            s.name as status_name,s.color status_color";
            $join = " JOIN customers c ON p.customer_id = c.id ";
            $join .= " JOIN project_statuses s ON p.status_id = s.id ";
            $where =" (date(p.end_date) BETWEEN STR_TO_DATE('$from_date', '%d/%m/%Y') AND STR_TO_DATE('$to_date', '%d/%m/%Y')) " ;
            $where .=" AND p.name LIKE '%".$search."%' ";
            $params = [];
           
            if(!empty($stt)){
                $where.= "AND p.status_id IN (";               
                foreach($stt as $s){
                    $where .= $s==end($stt)?"$s":"$s,";
                }                
                $where .=")";
            }
            $count = count($this->__db->select($this->__table." p ","p.id",$join,$where));
            $projects = $this->__db->select($this->__table. " p ",$columns,$join,$where,$params,$page,$limit);

            $data = array(
                'code'=>200,
                'msg'=>'fetch projects list successfully!',
                'pages'=>$count%$limit==0?$count/$limit:intval($count/$limit)+1,
                'projects'=>$projects
            );
            return json_encode($data);
        }

        public function AddInstruction($id,$instruction){
            $user = unserialize($_SESSION['user']);
            $params = [
                'p_project'=>$id,
                'p_content'=>$instruction,
                'p_created'=>$user->id
            ];
            return $this->__db->executeStoredProcedure("ProjectInstructionInsert",$params);
        }
    }