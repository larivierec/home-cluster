console.log("MONGO_USER " + process.env.MONGO_USER);
console.log("MONGO_PASS " + process.env.MONGO_PASSWORD);
console.log("MONGO_DB " + process.env.MONGO_DBNAME);

dbName = process.env.MONGO_DBNAME;
dbNameStat = process.env.MONGO_DBNAME + "_stat";
db = new Mongo().getDB(dbName);
dbStat = new Mongo().getDB(dbNameStat);

db.createCollection("users", {capped: false});
dbStat.createCollection("users", {capped: false});

db.createUser({
  user: process.env.MONGO_USER, 
  pwd: process.env.MONGO_PASSWORD, 
  roles: [
    {
      role: "readWrite", db: dbName
    }
  ]
});

dbStat.createUser({
  user: process.env.MONGO_USER, 
  pwd: process.env.MONGO_PASSWORD, 
  roles: [
    {
      role: "readWrite", db: dbNameStat
    }
  ]
});