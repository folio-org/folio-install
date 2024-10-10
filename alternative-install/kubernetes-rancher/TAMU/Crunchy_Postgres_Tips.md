# Crunchy Postgres Pro-Tips

#### A good resource on operating using Crunchy/Patroni:
https://community.pivotal.io/s/article/How-to-Use-pgbackrest-to-bootstrap-or-add-replica-to-HA-Patroni?language=en_US

#### Before a large data import, restore or data change it is generally a good idea to pause the cluster and disable replication.<BR>
##### The following are the commands and config:

`patronictl -c /etc/patroni/crunchy.yml pause`

`patronictl -c /etc/patroni/crunchy.yml edit-config`

##### Set and save the following parameters:
```
loop_wait: 10
master_start_timeout: 300
maximum_lag_on_failover: 1048576
postgresql:
  parameters:
    archive_mode: 'off'
    max_connections: 1000
    max_locks_per_transaction: 64
    max_prepared_transactions: 0
    max_replication_slots: 10
    max_wal_senders: 0
    max_worker_processes: 12
    shared_buffers: 16384MB
    temp_buffers: 128MB
    track_commit_timestamp: false
    wal_keep_segments: 32
    wal_level: minimal
    wal_log_hints: true
    work_mem: 128MB
  recovery_conf:
    restore_command: /usr/bin/pgbackrest --stanza=crunchy archive-get %f %p
    standby_mode: true
  use_pg_rewind: true
  use_slots: false
retry_timeout: 10
synchronous_mode: false
ttl: 30
```

#### Crunchy Patroni commands:

Edit the DCS config:
`patronictl -c /etc/patroni/crunchy.yml edit-config`

Pause the Cluster:
`patronictl -c /etc/patroni/crunchy.yml pause`

Resume the Cluster:
`patronictl -c /etc/patroni/crunchy.yml resume`

Reinit a Cluster Member Node:
`patronictl -c /etc/patroni/crunchy.yml reinit crunchy <member>`

List Nodes:
`patronictl -c /etc/patroni/crunchy.yml list -e`

Failoiver to Another Node:
`patronictl -c /etc/patroni/crunchy.yml failover crunchy`

Reload the Config for Cluster Nodes:
`patronictl -c /etc/patroni/crunchy.yml reload crunchy`

Restart the Node with Role:
`patronictl -c /etc/patroni/crunchy.yml restart crunchy -r <master> OR <replica>`

#### On the srv-etcd nodes:

`etcdctl cluster-health`


#### NEW METHOD To re-create Postgres replica from primary Postgres server...

1.) Start backup on Primary PG host as postgres user:<BR>
`psql -c "select pg_start_backup('initial_backup');"`

2.) Stop the backup on Primary PG host as postgres user:<BR>
`psql -c "select pg_stop_backup();"`

3.) Reinit replica Postgres servers:<BR>
`patronictl -c /etc/patroni/crunchy.yml reinit crunchy <pg2> <pg3>`

4.) Initiate a stanza backup on pgbackrest for replica sync as postgres user:<BR>
`pgbackrest --stanza=crunchy --type=full --log-level-console=info backup`


#### OLD METHOD To re-create Postgres replicas from primary Postgres server...

1.) Pause Crunchy cluster:<BR>
`patronictl -c /etc/patroni/crunchy.yml pause`

2.) Start backup on Primary PG host as postgres user:<BR>
`psql -c "select pg_start_backup('initial_backup');"`

3.) Stop Patroni service on replica servers:<BR>
`systemctl stop patroni@crunchy.service`

4.) Sync data to a replica with Postgres/Patroni service stopped:<BR>
`rsync -cva --inplace --exclude=*pg_xlog* /data/pg_data postgres@<REPLICA_IP>:/data`<BR>
`rsync -cva --inplace --exclude=*pg_xlog* /data/pg_data postgres@<REPLICA_IP>:/data`

5.) Stop the backup on Primary PG host as postgres user:<BR>
`psql -c "select pg_stop_backup();"`

6.) Start Patroni service on replica servers:<BR>
`systemctl start patroni@crunchy.service`

7.) Initiate a stanza backup on pgbackrest for replica sync as postgres user:<BR>
`pgbackrest --stanza=crunchy --type=full --log-level-console=info backup`

8.) ***OPTIONAL*** Reinit replica Postgres servers:<BR>
`patronictl -c /etc/patroni/crunchy.yml reinit crunchy <pg2> <pg3>`

9.) Resume Crunchy cluster:<BR>
`patronictl -c /etc/patroni/crunchy.yml resume`
