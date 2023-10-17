<?php
class Database
{
    private $__conn;
    public function __construct()
    {
        global $db_config;
        $this->__conn = Connection::getInstance($db_config);
    }
    function callStoredProcedureWithMultipleResults($procedure, $params)
    {
        try {
            // Create a prepared statement for calling the stored procedure
            $stmt = $this->__conn->prepare("CALL $procedure");

            // Bind parameters
            foreach ($params as $paramName => $paramValue) {
                $paramType = gettype($paramValue);
                $pdoParamType = PDO::PARAM_STR; // Default to string

                // Set the PDO parameter type based on the parameter's type
                switch ($paramType) {
                    case 'integer':
                        $pdoParamType = PDO::PARAM_INT;
                        break;
                    case 'boolean':
                        $pdoParamType = PDO::PARAM_BOOL;
                        break;
                    // Add more cases as needed

                }
                $stmt->bindParam($paramName, $params[$paramName], $pdoParamType);
            }

            // Execute the stored procedure
            $stmt->execute();

            $results = array();

            do {
                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                if ($result) {
                    $results[] = $result;
                }
            } while ($stmt->nextRowset());

            $stmt->closeCursor();

            return $results;
        } catch (PDOException $e) {
            return false;
        }
    }


    function callStoredProcedure($procedureName, $params = [])
    {
        try {
            // Xây dựng chuỗi truy vấn gọi stored procedure với các tham số dưới dạng placeholders
            $paramPlaceholder = implode(',', array_fill(0, count($params), '?'));

            // Chuẩn bị truy vấn gọi stored procedure
            $sql = "CALL $procedureName($paramPlaceholder)";
            $stmt = $this->__conn->prepare($sql);

            // Gán giá trị cho các tham số đầu vào
            foreach ($params as $index => $paramValue) {
                // Kiểm tra kiểu dữ liệu của tham số và gán kiểu dữ liệu tương ứng
                if (is_int($paramValue)) {
                    $stmt->bindValue($index + 1, $paramValue, PDO::PARAM_INT);
                } else {
                    $stmt->bindValue($index + 1, $paramValue, PDO::PARAM_STR);
                }
            }

            // Thực hiện truy vấn
            $stmt->execute();

            // Lấy kết quả trả về từ stored procedure
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $result;
        } catch (PDOException $e) {
            echo "Lỗi kết nối đến cơ sở dữ liệu: " . $e->getMessage();
            return false;
        }
    }

    function callFunction($f, $params)
    {

        global $db_config;
        $this->__conn = Connection::getInstance($db_config);

        // khai báo mảng chứa các key của mảng
        $keys = array_keys($params);
        $values = array_values(($params));

        $sql = "SELECT $f(";
        foreach ($params as $key => $value) {
            $sql .= ":$key" . ($value == end($params) ? "" : ",");
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

    function callAnyStoredProcedure($procedureName, $params = [])
    {
        try {

            // Xây dựng chuỗi truy vấn gọi stored procedure
            $paramPlaceholder = implode(',', array_fill(0, count($params), '?'));

            // Chuẩn bị truy vấn gọi procedure
            $sql = "CALL $procedureName($paramPlaceholder)";
            $stmt = $this->__conn->prepare($sql);

            // Gán giá trị cho các tham số đầu vào
            foreach ($params as $index => $paramValue) {
                $stmt->bindValue($index + 1, $paramValue);
            }

            // Thực hiện truy vấn
            $stmt->execute();

            // Lấy kết quả trả về từ procedure
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return $result;
        } catch (PDOException $e) {
            echo "Lỗi kết nối đến cơ sở dữ liệu: " . $e->getMessage();
            return false;
        }
    }

    function executeStoredProcedure($procedureName, $params = array())
    {
        try {
            $paramStr = '';
            foreach ($params as $paramName => $paramValue) {
                $paramStr .= ":$paramName, ";
            }
            $paramStr = rtrim($paramStr, ', ');

            $sql = "CALL $procedureName($paramStr)";

            // Tạo đối tượng câu lệnh SQL
            $stmt = $this->__conn->prepare($sql);

            // Bind giá trị cho các tham số IN
            foreach ($params as $paramName => &$paramValue) {
                $stmt->bindParam(":$paramName", $paramValue);
            }

            // Thực thi stored procedure
            $stmt->execute();

            // Lấy kết quả từ truy vấn SELECT
            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            return $result;
        } catch (PDOException $e) {
            // Xử lý lỗi nếu cần
            echo "Lỗi: " . $e->getMessage();
            return false;
        }
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