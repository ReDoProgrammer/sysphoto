<?php
    class ProjectModel extends Model{
        protected $__table = 'project_list';

        public function create($data){
            return $this->__db->insert($this->__table,$data);
        }

        public function detail($id){
            //select($table, $columns = '*',$join ='', $where = '',$params=[],$page = 1,$limit = 0,$orderby='',$groupby='')
            $columns = "p.id, p.name, p.description, p.instruction,p.idkh, count(t.id) tasks_number,st.stt_task_name, 
                        DATE_FORMAT(p.start_date, '%d %b, %Y %H:%m') as start_date, 
                        DATE_FORMAT(p.end_date, '%d %b, %Y %H:%m') as end_date, p.urgent,
                        p.idcb,cb.ten_combo,cb.mau_sac,p.idlevels, s.stt_job_name, s.color_sttj";
            $join = " JOIN custom c ON p.idkh = c.id ";
            $join .= " JOIN status_job s ON p.status = s.id ";
            $join .= " LEFT JOIN task_list t ON t.project_id = p.id";
            $join .= " JOIN status_task st ON t.status = st.id";
            $join .= " LEFT JOIN combo cb ON p.idcb = cb.id";
            $where =" p.id = $id" ;
            // $groupby = "p.id,st.stt_task_name";
            $groupby = "";
            return $this->__db->select($this->__table. " p ",$columns,$join,$where,[],1,0,'',$groupby);
        }

        public function getList($from_date,$to_date,$stt,$search,$page = 1,$limit = 10){
            $columns = "p.id,c.name_ct_mh,p.name,DATE_FORMAT(p.start_date, '%m/%d/%Y %H:%i') start_date, DATE_FORMAT(p.end_date, '%m/%d/%Y %H:%i') end_date, s.stt_job_name,s.color_sttj";
            $join = " JOIN custom c ON p.idkh = c.id ";
            $join .= " JOIN status_job s ON p.status = s.id ";
            $where =" (date(p.end_date) BETWEEN STR_TO_DATE('$from_date', '%d/%m/%Y') AND STR_TO_DATE('$to_date', '%d/%m/%Y')) " ;
            $where .=" AND p.name LIKE '%".$search."%' ";
            $params = [];
           
            if(!empty($stt)){
                $where.= "AND p.status IN (";               
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
    }