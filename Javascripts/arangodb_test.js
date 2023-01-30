// Modern JavaScript
import { Database, aql } from "arangojs";

const db = new Database(
  {
    url: "http://localhost:8529"
  }
);

db.database("Code_templates");
db.useBasicAuth("nonedb_dev", "Xuser900");

(async function() {
  const now = Date.now();
  console.log(now);
  try {
    const cursor = await db.query(aql`
      RETURN ${now}
    `);
    const result = await cursor.next();
    // ...
  } catch (err) {
    // ...
  }
})();