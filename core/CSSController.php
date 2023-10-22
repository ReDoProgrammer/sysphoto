<?php
/**
 * base controller
 */
class CSSController extends Controller
{
    function __construct()
    {

        if (!empty($_SESSION['user'])) {
            $user = unserialize($_SESSION['user']);
            if ($user->role_id != 3) {
                header('Location: ' . _WEB_ROOT . '/css/login');
                exit;
            }
        } else {
            header('Location: ' . _WEB_ROOT . '/css/login');
            exit;
        }
    }

}