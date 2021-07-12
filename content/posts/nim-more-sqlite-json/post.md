@date 2021-07-12
@title More Sqlite and Json
Ok just writing this so that I remember how to do it - a couple of examples of working with json and sqlite.

Given an example schema:

```
create table players ( name text, batting json );
```

And batting data looks something like this (keyed game format with data objects per format):

```
{
  "T20I": {
    "runs": 1000,
    "average": 50
  }
}
```

We can:

### Extract a specific stat per format

@snippet 1.sql

### Alias and filter

@snippet 2.sql

| name | average |
| ---- | ------- |
| V. Kohli | 52.65 |
| M. Hayden | 51.33 |
| etc | ... |

### Join based on json data

Note: an extra table is required to demonstrate the join:

```
create table teams ( id integer, name text );
```

And players requires an extra column `teams json` which is just a json array of integers representing ids in the teams table. Obviously this has the negative of no enforced constraint so data integrity takes a hit, but it might be good enough - not sure. I was just feeling lazy and couldn't be bothered to introduce a many-to-many table.

@snippet 3.sql

Note: json\_each can be aliased just like any other table.

| teams.name | players.name |
| ---------- | ------------ |
| Australia | Kane Richardson |
| Australia | Glenn Maxwell |
| etc | ... |
