<?php
class User
{
    public $id;
    public $fullname;
    public $acronym;
    public $email;
    public $role_id;
    public $role_name;
    public $task_getable;

    public function __construct($id,$fullname,$acronym, $email,$role_id,$role_name,$task_getable)
    {
        $this->id = $id;
        $this->firstname = $fullname;
        $this->acronym = $acronym;
        $this->email = $email;
        $this->role_id = $role_id;
        $this->role_name = $role_name;
        $this->task_getable = $task_getable;
    }
}