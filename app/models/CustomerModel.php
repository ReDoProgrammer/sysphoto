<?php
class CustomerModel extends Model
{
    protected $__table = 'customers';


    public function CheckMailExists($email,$id=0){
        $where = $id>0?"email != '$email' AND id = $id ":" email = '$email'";
        return count($this->__db->select($this->__table,"id","",$where))==0;
    }

    public function JoinDetail($id){
        $params = ['p_id'=>$id];
        return $this->__db->executeStoredProcedure('CustomerDetailJoin',$params);
    }

    public function CustomerDetail($id){
        return $this->__db->select($this->__table,"*","","id = $id");
    }

    public function InsertCustomer($group_id, $name, $email, $password, $customer_url,
    $color_mode,$output,$size,$is_straighten,$straighten_remark,$tv,$fire,$sky,$grass,
    $nationtal_style,$cloud ,$style_remark)
    {
        try {
            $user = unserialize($_SESSION['user']);
            $params = [
                'p_group_id' => $group_id,
                'p_name' => $name,
                'p_email' => $email,
                'p_password' => $password,
                'p_customer_url' => $customer_url,
                'p_color_mode'=>$color_mode, 'p_output'=>$output,'p_size'=>$size,'p_is_straighten'=>$is_straighten,
                'p_straighten_remark'=>$straighten_remark,'p_tv'=>$tv,'p_fire'=>$fire,'p_sky'=>$sky,'p_grass'=>$grass,
                'p_national_style'=>$nationtal_style,'p_cloud'=>$cloud,'p_style_remark'=>$style_remark,
                'p_created_by' => $user->id
            ];
            return $this->__db->executeStoredProcedure('CustomerInsert',$params);
        } catch (Exception $e) {
            return $e->getMessage();
        }
    }

    public function UpdateCustomer($id,$group_id, $name, $email, $password, $customer_url,
    $color_mode,$output,$size,$is_straighten,$straighten_remark,$tv,$fire,$sky,$grass,
    $nationtal_style,$cloud ,$style_remark)
    {
        try {
            $user = unserialize($_SESSION['user']);
            $params = [
                'p_id'=>$id,
                'p_group_id' => $group_id,
                'p_name' => $name,
                'p_email' => $email,
                'p_password' => $password,
                'p_customer_url' => $customer_url,
                'p_color_mode'=>$color_mode, 'p_output'=>$output,'p_size'=>$size,'p_is_straighten'=>$is_straighten,
                'p_straighten_remark'=>$straighten_remark,'p_tv'=>$tv,'p_fire'=>$fire,'p_sky'=>$sky,'p_grass'=>$grass,
                'p_national_style'=>$nationtal_style,'p_cloud'=>$cloud,'p_style_remark'=>$style_remark,
                'p_updated_by' => $user->id
            ];
            return $this->__db->executeStoredProcedure('CustomerUpdate',$params);
        } catch (Exception $e) {
            return $e->getMessage();
        }
    }

    public function AllCustomer(){
        return $this->__db->select($this->__table,"id,acronym");
    }
    public function getList($page = 1, $limit = 10, $group = '', $search = '')
    {

        $columns = "c.id,c.name as fullname,c.acronym,c.email,c.avatar, 
                    c.customer_url, g.name as group_name, cp.name as company";

        $join = "  JOIN customer_groups g ON c.group_id = g.id";
        $join .= " LEFT JOIN companies cp ON c.company_id = cp.id ";

        $where = " (c.name LIKE '%" . $search . "%' ";
        $where .= " OR c.acronym LIKE '%" . $search . "%' ";
        $where .= " OR c.email LIKE '%" . $search . "%' ";
        $where .= " OR cp.name LIKE '%" . $search . "%' )";

        if (is_int($group)) {
            $where .= " AND c.group_id = $group ";
        }
        $params = [];

        $count = count($this->__db->select($this->__table . " c", "c.id", $join, $where));

        $orderby = "c.created_at DESC, c.name ASC";
        $customers = $this->__db->select($this->__table . " c ", $columns, $join, $where, $params, $page, $limit,$orderby);
        return array(
            'customers' => $customers,
            'pages' => $count % $limit == 0 ? $count / $limit : intval($count / $limit) + 1,
            'group' => $group
        );
    }
}