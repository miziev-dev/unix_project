// @file init-replica.js
// @brief JS скрипт для инициализации Replica Set в MongoDB
rs.initiate({
    _id: "rs0",
    members: [
        { _id: 0, host: "mongo-primary:27017", priority: 2 },
        { _id: 1, host: "mongo-secondary:27017", priority: 1 },
        { _id: 2, host: "mongo-arbiter:27017", arbiterOnly: true }
    ]
});
