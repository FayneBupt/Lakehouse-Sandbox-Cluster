CREATE CATALOG paimon_catalog WITH (
    'type' = 'paimon',
    'metastore' = 'hive',
    'uri' = 'thrift://paimon-hive-metastore:9083',
    'warehouse' = 'hdfs://paimon-namenode:8020/paimon/warehouse',
    'hadoop-conf-dir' = '/opt/hadoop/conf'
);

USE CATALOG paimon_catalog;

CREATE DATABASE IF NOT EXISTS doris_paimon_db;
USE doris_paimon_db;

DROP TABLE IF EXISTS doris_insert_test;
CREATE TABLE doris_insert_test (
    id INT PRIMARY KEY NOT ENFORCED,
    name STRING,
    dt STRING
);

INSERT INTO doris_insert_test VALUES
(1, 'Doris', '2024-05-01'),
(2, 'Paimon', '2024-05-01'),
(3, 'Flink', '2024-05-02');
