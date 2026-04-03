CREATE CATALOG paimon_catalog WITH (
    'type' = 'paimon',
    'metastore' = 'hive',
    'uri' = 'thrift://paimon-hive-metastore:9083',
    'warehouse' = 'hdfs://paimon-namenode:8020/paimon/warehouse'
);

USE CATALOG paimon_catalog;

SET 'sql-client.execution.result-mode' = 'tableau';
SET 'execution.runtime-mode' = 'batch';
SELECT * FROM test_paimon_table;
