# 🌊 Lakehouse-Sandbox-Cluster

[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://www.docker.com/)

**Lakehouse-Sandbox-Cluster** 是一个极简、轻量的 Docker Compose 编排项目，专门为测试和开发湖仓一体（Lakehouse）组件而设计的开箱即用沙盒集群。

在进行像 Apache Doris 等大型计算引擎的外部数据源集成开发时，我们往往需要一个底层的存储和元数据环境。该项目提供了 Paimon 等湖仓格式运行所需的底层存储（HDFS）、元数据管理（Hive Metastore）以及强大的建表与写入引擎（Flink），帮助你快速搭建起一个沙盒环境，告别繁琐的环境配置。

它可以完美作为 **[ForgeLoopAI](https://github.com/your-username/ForgeLoopAI)** 自动化研发闭环中的基础设施依赖。

---

## 🌟 核心组件

该环境通过 `docker-compose` 一键拉起以下服务：

- **Hadoop HDFS (NameNode & DataNode)**：版本 2.8，作为湖仓底层分布式文件系统存储。
- **Hive Metastore**：版本 3.1.3 (内置 Derby 数据库)，作为外部 Catalog 的元数据中心。
- **Apache Flink (JobManager & TaskManager)**：版本 1.18.1，挂载了 Paimon 和 Hadoop 的依赖，通过 Flink SQL 提供开箱即用的建表和数据写入能力。

---

## 🚀 快速开始

### 1. 前置要求
- 安装 Docker 和 Docker Compose
- 确保宿主机可以正常访问互联网（用于拉取 Docker 镜像）

### 2. 启动集群

在项目根目录下执行以下命令启动所有组件：

```bash
sudo docker-compose up -d
```

等待十几秒钟，可以通过以下命令检查所有容器是否正常 `Up`：

```bash
sudo docker-compose ps
```

### 3. 初始化表与测试数据 (以 Paimon 为例)

环境启动后，我们可以利用 Flink 容器内置的 SQL Client 来创建 Paimon Catalog，并建表写入测试数据。
我们已经准备好了初始化脚本 `init.sql`，只需执行以下命令即可将其发送到 Flink 容器并执行：

```bash
sudo docker cp init.sql paimon-flink-jobmanager:/tmp/init.sql
sudo docker exec paimon-flink-jobmanager ./bin/sql-client.sh -f /tmp/init.sql
```

> **注意**：该脚本会在 HDFS 的 `/paimon/warehouse` 路径下创建数据库 `doris_paimon_db`，并创建表 `doris_insert_test`，写入几条测试数据。

---

## 🛠️ 验证与交互

### 验证 HDFS 上的文件
你可以直接通过 Namenode 容器查看 HDFS 上的底层文件：

```bash
sudo docker exec paimon-namenode hadoop fs -ls -R /paimon/warehouse/doris_paimon_db.db/doris_insert_test
```

### 验证 Flink 侧的读取
随时进入 Flink SQL 客户端进行交互式查询：

```bash
sudo docker exec -it paimon-flink-jobmanager ./bin/sql-client.sh
```

在 SQL Client 中执行以下语句以查询刚才写入的数据：

```sql
CREATE CATALOG paimon_catalog WITH (
    'type' = 'paimon',
    'metastore' = 'hive',
    'uri' = 'thrift://paimon-hive-metastore:9083',
    'warehouse' = 'hdfs://paimon-namenode:8020/paimon/warehouse',
    'hadoop-conf-dir' = '/opt/hadoop/conf'
);

USE CATALOG paimon_catalog;
USE doris_paimon_db;
SET 'sql-client.execution.result-mode' = 'tableau';
SET 'execution.runtime-mode' = 'batch';

SELECT * FROM doris_insert_test;
```

---

## 🤖 与 ForgeLoopAI 集成

作为 AI 自动开发闭环的周边环境，你可以将其直接配置在 `ForgeLoopAI` 的 `config.json` 中：

```json
{
  "deploy_commands": [
    "cd /path/to/Lakehouse-Sandbox-Cluster && docker-compose up -d",
    "sleep 15",
    "docker cp init.sql paimon-flink-jobmanager:/tmp/init.sql",
    "docker exec paimon-flink-jobmanager ./bin/sql-client.sh -f /tmp/init.sql"
  ]
}
```

---

## 🛑 停止与清理

测试完毕后，如果想停止集群并保留数据：
```bash
sudo docker-compose stop
```

如果想彻底销毁集群和网络（注意：HDFS 里的数据将丢失）：
```bash
sudo docker-compose down
```

## 📝 目录结构

- `docker-compose.yml`：核心的服务编排文件。
- `lib/`：存放 Flink 写入所需的 jar 包。
- `hadoop-conf/`：挂载给 Flink 使用的 Hadoop 配置文件目录。
- `init.sql`：一键建表和插入数据的 Flink SQL 脚本。
- `query.sql`：用于 Flink 侧验证查询的参考脚本。
