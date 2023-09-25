<?php
include_once 'User.php';
class EmployeeModel extends Model
{
    protected $__table = 'users u';
    public function getList()
    {
        $columns = "users.id, firstname,viettat,email,name_ut,date_created";
        $join = " join user_type on " . $this->__table . ".type = user_type.id";
        $data = $this->__db->select($this->__table, $columns, $join);
        return $data;
    }

    public function Login($email, $password, $role)
    {

        $columns = "u.id, u.firstname,u.viettat,u.email,u.type,ut.name_ut,u.date_created";
        $join = " JOIN user_type ut ON u.type = ut.id";
        $where = " email = '$email' ";
        $users = $this->__db->select($this->__table, $columns, $join, );
        if (count($users) > 0) {
            $where .= " AND password = '" . md5($password) . "'";
            $users = $this->__db->select($this->__table, $columns, $join, $where);
            if (count($users) > 0) {
                $where .= " AND type IN (";

                foreach ($role as $r) {
                    $where .= $r == end($role) ? "$r" : "$r,";
                }
                $where .= ")";
                $users = $this->__db->select($this->__table, $columns, $join, $where);
                if (count($users) > 0) {
                    $ipaddress = gethostbyname("www.google.com");
                    $where .= " AND EXISTS (SELECT 1 FROM ip_photo WHERE dia_chi = '$ipaddress')";
                    $users = $this->__db->select($this->__table, $columns, $join, $where);
                    if (count($users) > 0) {
                        $user = new User($users[0]['firstname'], $users[0]['email'], $users[0]['type'], $users[0]['name_ut']);
                        $_SESSION['user'] = serialize($user);
                        $data = array(
                            'code'=>200,
                            'msg'=>'You have logged in successfully!'
                        );
                        return json_encode($data);
                    }else{
                        $data = array(
                            'code'=>403,
                            'msg'=>'Your IP address: '.$ipaddress.'.You are out of company!'
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