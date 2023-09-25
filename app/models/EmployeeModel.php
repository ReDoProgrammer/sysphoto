<?php
class EmployeeModel extends Model
{
    protected $__table = 'users';
    public function getList()
    {
        $columns = "users.id, firstname,viettat,email,name_ut,date_created";
        $join = " join user_type on " . $this->__table . ".type = user_type.id";
        $data = $this->__db->select($this->__table, $columns, $join);
        return $data;
    }

    public function Login($email, $password, $role)
    {
        $users = $this->__db->select($this->__table, "*", "", " email = '$email' ");
        if (count($users) > 0) {
            $users = $this->__db->select($this->__table, "*", "", " email = '$email' AND password = '" . md5($password) . "'");
            if (count($users) > 0) {
                $where = " email = '$email' AND password = '" . md5($password) . "' AND type IN (";
               
                foreach($role as $r){
                    $where.= $r == end($role)?"$r":"$r,";
                }
                $where .=")";
                $users = $this->__db->select($this->__table, "*", "",$where);
                if (count($users) > 0) {
                    $ipaddress = gethostbyname("www.google.com"); 
                    $where .=" AND ";
                    return json_encode($users);
                }else{
                    return "You have no permission to access this module!";
                }

            } else {
                return "Password not match!";
            }
        } else {
            return "Email not exist!";
        }
    }
}