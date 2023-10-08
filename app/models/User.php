<?php
class User
{
    public $id;
    public $fullname;
    public $acronym;
    public $email;
    public $role;
    public $roleName;
    public $task_getable;

    public function __construct($id,$fullname,$acronym, $email,$role,$roleName,$task_getable)
    {
        $this->id = $id;
        $this->firstname = $fullname;
        $this->acronym = $acronym;
        $this->email = $email;
        $this->role = $role;
        $this->roleName = $roleName;
        $this->task_getable = $task_getable;
    }
}