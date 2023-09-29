<?php
    class ProjectModel extends Model{
        protected $__table = 'project_list p';
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
            $count = count($this->__db->select($this->__table,"p.id",$join,$where));
            $projects = $this->__db->select($this->__table,$columns,$join,$where,$params,$page,$limit);

            $data = array(
                'code'=>200,
                'msg'=>'fetch projects list successfully!',
                'pages'=>$count%$limit==0?$count/$limit:intval($count/$limit)+1,
                'projects'=>$projects
            );
            return json_encode($data);
        }
    }