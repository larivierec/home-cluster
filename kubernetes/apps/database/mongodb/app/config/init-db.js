console.log("MONGO_USER " + process.env.MONGO_USER);
console.log("MONGO_PASS " + process.env.MONGO_PASSWORD);
console.log("MONGO_DB " + process.env.MONGO_DBNAME);

db = new Mongo().getDB(process.env.MONGO_DBNAME)
dbStat = new Mongo().getDB(process.env.MONGO_DBNAME + "_stat")

db.createCollection("users", {capped: false});
dbStat.createCollection("users", {capped: false});

db.createUser(
  {
    user: process.env.MONGO_USER, 
    pwd: process.env.MONGO_PASSWORD, 
    roles: [
      {
        role: "readWrite", db: process.env.MONGO_DBNAME
      }
    ]
  });

dbStat.createUser(
  {
    user: process.env.MONGO_USER, 
    pwd: process.env.MONGO_PASSWORD, 
    roles: [
      {
        role: "readWrite", db: process.env.MONGO_DBNAME + "_stat"
      }
    ]
  });