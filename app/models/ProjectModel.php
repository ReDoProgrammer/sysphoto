<?php
    class ProjectModel extends Model{
        protected $__table = 'project_list p';
        public function getList($from_date,$to_date,$stt,$search){
            $columns = "p.id,c.name_ct_mh,p.name,DATE_FORMAT(p.start_date, '%m/%d/%Y %H:%i') start_date, DATE_FORMAT(p.end_date, '%m/%d/%Y %H:%i') end_date, s.stt_job_name,s.color_sttj";
            $join = " JOIN custom c ON p.idkh = c.id ";
            $join .= " JOIN status_job s ON p.status = s.id ";
            $where =" p.end_date >=' $from_date' AND p.end_date <= '$to_date'" ;
            $where .=" AND p.name like '%".$search."%' ";
            if(!empty($stt)){
                $where.= "AND p.status IN (";               
                foreach($stt as $s){
                    if ($s === end($stt)) {
                       $where .=$s;
                    } else {
                        $where .="$s,";
                    }
                }
                rtrim($where,',');
                $where .=")";
            }
        //    return "SELECT $columns FROM $this->__table $join WHERE $where ";
            return $this->__db->select($this->__table,$columns,$join,$where);
        }
    }