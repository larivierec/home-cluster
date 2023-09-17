console.log("MONGO_USER " + {MONGO_USER});
console.log("MONGO_PASS " + {MONGO_PASSWORD});
console.log("MONGO_DB " + {MONGO_DBNAME});

db = new Mongo().getDB({MONGO_DBNAME})
dbStat = new Mongo().getDB({MONGO_DBNAME} + "_stat")

db.createCollection("users", {capped: false});
dbStat.createCollection("users", {capped: false});

db.createUser({
  user: {MONGO_USER},
  pwd: {MONGO_PASSWORD},
  roles: [
    {
      role: "readWrite", db: {MONGO_DBNAME}
    }
  ]
});

dbStat.createUser({
  user: {MONGO_USER},
  pwd: {MONGO_PASSWORD},
  roles: [
    {
      role: "readWrite", db: {MONGO_DBNAME} + "_stat"
    }
  ]
});