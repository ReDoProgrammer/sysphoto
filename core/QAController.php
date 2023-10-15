<?php
/**
 * base controller
 */
class QAController extends Controller
{
    function __construct()
    {

        if (!empty($_SESSION['user'])) {
            $user = unserialize($_SESSION['user']);
            if ($user->role_id != 5) {
                header('Location: ' . _WEB_ROOT . '/qa/login');
                exit;
            }
        } else {
            header('Location: ' . _WEB_ROOT . '/qa/login');
            exit;
        }
    }

}