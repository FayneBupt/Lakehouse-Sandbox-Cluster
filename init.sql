CREATE CATALOG paimon_catalog WITH (
    'type' = 'paimon',
    'metastore' = 'hive',
    'uri' = 'thrift://paimon-hive-metastore:9083',
    'warehouse' = 'hdfs://paimon-namenode:8020/user/hadoop/paimon/warehouse',
    'hadoop-conf-dir' = '/opt/hadoop/conf'
);

USE CATALOG paimon_catalog;

CREATE DATABASE IF NOT EXISTS doris_paimon_db;
USE doris_paimon_db;

DROP TABLE IF EXISTS doris_insert_test;
DROP TABLE IF EXISTS pk_partition_no_bucket;
DROP TABLE IF EXISTS append_partition_no_bucket;
DROP TABLE IF EXISTS pk_partition_bucketed;
DROP TABLE IF EXISTS append_partition_bucketed;

CREATE TABLE pk_partition_no_bucket (
    id INT,
    name STRING,
    dt STRING,
    PRIMARY KEY (id, dt) NOT ENFORCED
)
PARTITIONED BY (dt);

CREATE TABLE append_partition_no_bucket (
    id INT,
    name STRING,
    dt STRING
)
PARTITIONED BY (dt);

CREATE TABLE pk_partition_bucketed (
    id INT,
    name STRING,
    dt STRING,
    PRIMARY KEY (id, dt) NOT ENFORCED
)
PARTITIONED BY (dt)
WITH (
    'bucket' = '2',
    'bucket-key' = 'id'
);

CREATE TABLE append_partition_bucketed (
    id INT,
    name STRING,
    dt STRING
)
PARTITIONED BY (dt)
WITH (
    'bucket' = '2',
    'bucket-key' = 'id'
);

INSERT INTO pk_partition_no_bucket VALUES
(1, 'pk_nb_alice', '2024-05-01'),
(2, 'pk_nb_bob', '2024-05-01'),
(3, 'pk_nb_cindy', '2024-05-02');

INSERT INTO append_partition_no_bucket VALUES
(11, 'ap_nb_alice', '2024-05-01'),
(12, 'ap_nb_bob', '2024-05-01'),
(13, 'ap_nb_cindy', '2024-05-02');

INSERT INTO pk_partition_bucketed VALUES
(21, 'pk_bk_alice', '2024-05-01'),
(22, 'pk_bk_bob', '2024-05-01'),
(23, 'pk_bk_cindy', '2024-05-02');

INSERT INTO append_partition_bucketed VALUES
(31, 'ap_bk_alice', '2024-05-01'),
(32, 'ap_bk_bob', '2024-05-01'),
(33, 'ap_bk_cindy', '2024-05-02');
