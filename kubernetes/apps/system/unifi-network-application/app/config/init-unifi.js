db = new Mongo().getDB(process.env.MONGO_DB)
dbStat = new Mongo().getDB(process.env.MONGO_DB + "_stat")

db.createCollection("users", {capped: false});
dbStat.createCollection("users", {capped: false});

db.createUser(
  {
    user: process.env.MONGO_USER, 
    pwd: process.env.MONGO_PASSWORD, 
    roles: [
      {
        role: "readWrite", db: process.env.MONGO_DB
      }
    ]
  });

dbStat.createUser(
  {
    user: process.env.MONGO_USER, 
    pwd: process.env.MONGO_PASSWORD, 
    roles: [
      {
        role: "readWrite", db: process.env.MONGO_DB + "_stat"
      }
    ]
  });