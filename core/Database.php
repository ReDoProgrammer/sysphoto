<?php
class Database
{
    private $__conn;
    public function __construct()
    {
        global $db_config;
        $this->__conn = Connection::getInstance($db_config);
    }



    function callMySqlFunction($f, $params)
    {

        global $db_config;
        $this->__conn = Connection::getInstance($db_config);
        
        // khai báo mảng chứa các key của mảng
        $keys = array_keys($params);
        $values = array_values(($params));

        $sql = "SELECT $f(";
        foreach ($params as $key => $value) {
           $sql.=":$key".($value == end($params)?"":",");
        }        

        $sql .= ") AS result";
        $stmt = $this->__conn->prepare($sql);



        $paramCount = count($params);
        for ($i = 0; $i < $paramCount; $i++) {
            $stmt->bindValue(":$keys[$i]", $values[$i]);
        }

        $stmt->execute();

        return $stmt->fetch(PDO::FETCH_ASSOC)['result'];
    }



    public function select($table, $columns = '*', $join = '', $where = '', $params = [], $page = 1, $limit = 0, $orderby = '', $groupby = '')
    {
        $sql = "SELECT $columns FROM $table";
        if (!empty($join)) {
            $sql .= $join;
        }
        if (!empty($where)) {
            $sql .= " WHERE $where";
        }
        if (!empty($orderby)) {
            $sql .= " ORDER BY $orderby ";
        }
        if (!empty($groupby)) {
            $sql .= " GROUP BY $groupby ";
        }
        if ($limit > 0) {
            $sql .= " LIMIT " . ($page - 1) * $limit . ",$limit";
        }
        $stmt = $this->__conn->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function insert($table, $data)
    {
        // Tạo danh sách các trường và giá trị
        $columns = implode(', ', array_keys($data));
        $placeholders = ':' . implode(', :', array_keys($data));

        // Tạo câu lệnh SQL với prepared statement
        $sql = "INSERT INTO $table ($columns) VALUES ($placeholders)";



        // Tạo prepared statement
        $stmt = $this->__conn->prepare($sql);

        // Bind giá trị vào các placeholders và thực thi truy vấn
        foreach ($data as $key => $value) {
            $stmt->bindValue(':' . $key, $value);
        }

        $stmt->execute();

        return $this->__conn->lastInsertId();
    }

    public function update($table, $data, $where, $params = [])
    {
        try {
            $set = [];
            foreach ($data as $key => $value) {
                $set[] = "$key = :$key";
            }
            $set = implode(', ', $set);
            $sql = "UPDATE $table SET $set WHERE $where";
            $stmt = $this->__conn->prepare($sql);

            $stmt->execute(array_merge($data, $params));
            return $stmt->rowCount() > 0;
        } catch (Exception $e) {
            return $e->getMessage();
        }
    }
    public function delete($table, $where, $params = [])
    {
        try {

            // Xây dựng câu truy vấn SQL
            $sql = "DELETE FROM $table WHERE $where";

            // Chuẩn bị và thực thi câu truy vấn
            $stmt = $this->__conn->prepare($sql);
            $stmt->execute($params);

            return $stmt->rowCount() > 0; // Xóa dữ liệu thành công
        } catch (PDOException $e) {
            return $e->getMessage(); // Lỗi khi xóa dữ liệu
        }
    }
}