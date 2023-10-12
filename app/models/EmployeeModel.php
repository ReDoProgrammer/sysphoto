<?php

class EmployeeModel extends Model
{
    protected $__table = 'users u';


    function getEditors($level){
        $columns = " u.acronym,u.id ";
        $join = " JOIN employee_groups g ON u.editor_group_id = g.id";
        $where = " FIND_IN_SET('$level', g.levels) > 0 ";
        return $this->__db->select($this->__table, $columns, $join,$where);
    }

    function getQAs($level){
        $columns = " u.acronym,u.id ";
        $join = " JOIN employee_groups g ON u.qa_group_id = g.id";
        $where = " FIND_IN_SET('$level', g.levels) > 0 ";
        return $this->__db->select($this->__table, $columns, $join,$where);
    }

    public function getList()
    {
        $columns = "users.id, firstname,viettat,email,name_ut,date_created";
        $join = " join user_type on " . $this->__table . ".type = user_type.id";
        $data = $this->__db->select($this->__table, $columns, $join);
        return $data;
    }

    public function Login($email, $password, $role)
    {
        $ip = gethostbyname("www.google.com");
        $params = [
            'p_email'=>$email,
            'p_password'=>$password,
            'p_role'=>$role,
            'p_ip'=>$ip
        ];
        return $this->__db->executeStoredProcedure("UserLogin",$params);
    }
}