select name, cast(json_extract(batting, '$.T20I.average') as decimal) as average
from players
where average > 50
order by average desc
