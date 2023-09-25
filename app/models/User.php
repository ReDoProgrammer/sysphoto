<?php
class User
{
    public $firstname;
    public $email;
    public $role;
    public $roleName;

    public function __construct($firstname, $email,$role,$roleName)
    {
        $this->firstname = $firstname;
        $this->email = $email;
        $this->role = $role;
        $this->roleName = $roleName;
    }
}