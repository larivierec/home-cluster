dbName = process.env.MONGO_DBNAME;
dbNameStat = process.env.MONGO_DBNAME + "_stat";
// db = new Mongo().getDB(dbName);
// dbStat = new Mongo().getDB(dbNameStat);

// db.createCollection("users", {capped: false});
// dbStat.createCollection("users", {capped: false});

db = db.getSiblingDB(dbName);
db.createUser({
  user: process.env.MONGO_USER, 
  pwd: process.env.MONGO_PASSWORD, 
  roles: [
    {
      role: "readWrite", db: dbName
    }
  ]
});

db = db.getSiblingDB(dbNameStat);
db.createUser({
  user: process.env.MONGO_USER, 
  pwd: process.env.MONGO_PASSWORD, 
  roles: [
    {
      role: "readWrite", db: dbNameStat
    }
  ]
});