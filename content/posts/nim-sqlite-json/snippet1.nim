import json
import strutils # for parseInt
import db_sqlite

let
  db = open("example.db", "", "", "")
  data = %*{ "id": 123, "value": "foobar" }

db.exec(sql"create table example ( data json not null )")

# insert the json data from above as a string ($ stringifies the JSONObject)
db.exec(sql"insert into example (data) values (?)", $data)

# extract the id on it's own from the row
let id = db.getValue(sql"select json_extract(data, '$.id') from example limit 1")

# do something with the row to show it worked - should print 246
echo 2 * parseInt(id)

db.close()
