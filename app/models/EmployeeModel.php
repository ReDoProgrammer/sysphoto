<?php

class EmployeeModel extends Model
{
    protected $__table = 'users u';


    function getEditors($level){
        $columns = " u.viettat,u.id ";
        $join = " JOIN employee_group g ON u.groupe = g.group_id";
        $where = " FIND_IN_SET('$level', g.levels) > 0 ";
        return $this->__db->select($this->__table, $columns, $join,$where);
    }

    function getQAs($level){
        $columns = " u.viettat,u.id ";
        $join = " JOIN employee_group g ON u.groupqa = g.group_id";
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

        $columns = "u.id, u.fullname,u.acronym,u.email,u.task_getable,u.type_id,ut.name as type_name,u.created_at";
        $join = " JOIN user_types ut ON u.type_id = ut.id";
        $where = " email = '$email' ";
        $users = $this->__db->select($this->__table, $columns, $join, );
        if (count($users) > 0) {
            $where .= " AND password = '" . md5($password) . "'";
            $users = $this->__db->select($this->__table, $columns, $join, $where);
            if (count($users) > 0) {
                $where .= " AND type_id IN (";

                foreach ($role as $r) {
                    $where .= $r == end($role) ? "$r" : "$r,";
                }
                $where .= ")";
                $users = $this->__db->select($this->__table, $columns, $join, $where);
                if (count($users) > 0) {
                    $ipaddress = gethostbyname("www.google.com");
                    $where .= " AND EXISTS (SELECT 1 FROM ips WHERE address = '$ipaddress')";
                    $users = $this->__db->select($this->__table, $columns, $join, $where);
                    if (count($users) > 0) {
                        $user = new User($users[0]['fullname'], $users[0]['email'], $users[0]['type_id'], $users[0]['type_name'],$users[0]['task_getable']);
                       
                        $_SESSION['user'] = serialize($user);
                        $data = array(
                            'code'=>200,
                            'msg'=>'You have logged in successfully!'
                        );
                        return json_encode($data);
                    }else{
                        $data = array(
                            'code'=>403,
                            'msg'=>'Your IP address: '.$ipaddress.' .You are out of company!'
                        );
                        return json_encode($data);
                    }

                } else {
                    $data = array(
                        'code'=>403,
                        'msg'=>'You have no permission to access this module!'
                    );
                    return json_encode($data);
                }

            } else {
                $data = array(
                    'code'=>400,
                    'msg'=>'Password not match!'
                );
                return json_encode($data);
            }
        } else {
            $data = array(
                'code'=>404,
                'msg'=>'Email not exist!'
            );
           return json_encode($data);
        }
    }
}