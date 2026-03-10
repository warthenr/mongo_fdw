// This script runs inside the MongoDB container as the root user (edb/edb)
// to create the test databases and grant the required roles.

const dbs = ["mongo_fdw_regress", "mongo_fdw_regress1", "mongo_fdw_regress2"];

for (const dbName of dbs) {
  const d = db.getSiblingDB(dbName);
  // createUser will fail if the user already exists; ignore errors
  try {
    d.createUser({
      user: "edb",
      pwd: "edb",
      roles: [
        { role: "dbOwner", db: dbName },
        { role: "readWrite", db: dbName },
      ],
    });
  } catch (e) {
    // User may already exist from MONGO_INITDB_ROOT – that's fine
    print("Note: " + e.message);
  }
}
