<?php
    class Database{
        private $__conn;
        public function __construct(){
            global $db_config;
            $this->__conn = Connection::getInstance($db_config);           
        }

        public function select($table, $columns = '*',$join ='', $where = '',$params=[],$page = 1,$limit = 0,$orderby='',$groupby='') {
            $sql = "SELECT $columns FROM $table";
            if(!empty($join)){
                $sql .=$join;
            }
            if (!empty($where)) {
                $sql .= " WHERE $where";
            }
            if($limit>0){
                $sql .=" LIMIT ".($page-1)*$limit.",$limit";
            }

            $stmt = $this->__conn->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        }
    
        public function insert($table, $data) {
            $columns = implode(', ', array_keys($data));
            $values = ':' . implode(', :', array_keys($data));
            $sql = "INSERT INTO $table ($columns) VALUES ($values)";
            $stmt = $this->__conn->prepare($sql);
            $stmt->execute($data);
            return $this->__conn->lastInsertId();
        }
    
        public function update($table, $data, $where, $params = []) {
            $set = [];
            foreach ($data as $key => $value) {
                $set[] = "$key = :$key";
            }
            $set = implode(', ', $set);
            $sql = "UPDATE $table SET $set WHERE $where";
            $stmt = $this->__conn->prepare($sql);
            $stmt->execute(array_merge($data, $params));
            return $stmt->rowCount();
        }
    
        public function delete($table, $where, $params = []) {
            $sql = "DELETE FROM $table WHERE $where";
            $stmt = $this->__conn->prepare($sql);
            $stmt->execute($params);
            return $stmt->rowCount();
        }
    }