#!/bin/bash

# Initialize the Config Server replica set
echo "Initializing Config Server replica set..."
docker exec -i mongo-config-srv mongosh --port 27017 --eval '
rs.initiate({
  _id: "config_server",
  configsvr: true,
  members: [{ _id: 0, host: "mongo-config-srv:27017" }]
})'

# Wait for the Config Server to become primary
sleep 15

# Initialize Shard 1 replica set
echo "Initializing Shard 1 (sh1-rs) replica set..."
docker exec -i sh1-repl-1 mongosh --port 27018 --eval '
rs.initiate({
  _id: "sh1-rs",
  members: [
    { _id: 0, host: "sh1-repl-1:27018" },
    { _id: 1, host: "sh1-repl-2:27019" },
    { _id: 2, host: "sh1-repl-3:27020" }
  ]
})'

# Wait for Shard 1
sleep 15

# Initialize Shard 2 replica set
echo "Initializing Shard 2 (sh2-rs) replica set..."
docker exec -i sh2-repl-1 mongosh --port 27021 --eval '
rs.initiate({
  _id: "sh2-rs",
  members: [
    { _id: 0, host: "sh2-repl-1:27021" },
    { _id: 1, host: "sh2-repl-2:27022" },
    { _id: 2, host: "sh2-repl-3:27023" }
  ]
})'

# Wait for Shard 2
sleep 15

# Add Shard 1 and Shard 2 to the cluster via the Router - 
# We may add only one replica for each shard and the router will load a list of all other replicas from that first one.
echo "Adding Shard 1 to the cluster..."
docker exec -i mongo-router mongosh --port 27024 --eval '
sh.addShard("sh1-rs/sh1-repl-1:27018")'

echo "Adding Shard 2 to the cluster..."
docker exec -i mongo-router mongosh --port 27024 --eval '
sh.addShard("sh2-rs/sh2-repl-1:27021")'

echo "Pointing to DB for which sharding will be applied..."
docker exec -i mongo-router mongosh --port 27024 --eval '
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )'

echo "MongoDB cluster initialization complete!"