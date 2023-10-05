<?php
class CustomerModel extends Model
{
    protected $__table = 'customers';
    public function getList($page = 1, $limit = 10, $group = '',$search = '' )
    {

        $columns = "c.id,c.name as fullname,c.acronym,c.email,c.avatar, 
                    c.customer_url, g.name as group_name, cp.name as company";

        $join = "  JOIN customer_groups g ON c.group_id = g.id";
        $join .= " JOIN companies cp ON c.company_id = cp.id ";

        $where = " (c.name LIKE '%" . $search . "%' ";
        $where .= " OR c.acronym LIKE '%" . $search . "%' ";
        $where .= " OR c.email LIKE '%" . $search . "%' ";
        $where .= " OR cp.name LIKE '%" . $search . "%' )";

        if (is_int($group)) {
            $where .= " AND c.group_id = $group ";
        }
        $params = [];

        $count = count($this->__db->select($this->__table . " c", "c.id", $join, $where));
        $customers = $this->__db->select($this->__table . " c ", $columns, $join, $where, $params, $page, $limit);
        return array(
            'customers' => $customers,
            'pages' => $count % $limit == 0 ? $count / $limit : intval($count / $limit) + 1,
            'group'=>$group
        );
    }
}