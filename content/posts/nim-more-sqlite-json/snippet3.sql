select distinct teams.name, players.name
from players, json_each(players.teams) as player_teams
join teams on teams.id = player_teams.value
where player_teams.value = 2
