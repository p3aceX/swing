# Matchmaking API Flow

This document explains the matchmaking flow used by the app today, based on the current client code in `lib/features/matchmaking`.

## 1. Discover available grounds

Endpoint:
`GET /matchmaking/grounds`

Client call:
`searchGrounds(date, format, teamId?, overs?)`

Query params:
```text
date=2026-05-06
format=T20
teamId=team_123
overs=20
q=search term
```

What it does:
- Returns cricket ground units and their slots for a given date and format.
- Used when the user adds a ground/slot during the Create flow.
- Non-cricket units are excluded here; the picker is meant to show cricket venues only.

Expected response shape:
```json
{
  "grounds": [
    {
      "id": "ground_1",
      "name": "Swing Arena",
      "area": "Andheri",
      "photoUrl": "https://...",
      "unitId": "unit_abc",
      "slots": [
        {
          "time": "18:00",
          "endTime": "19:00",
          "unitId": "unit_abc",
          "hasOpponent": true,
          "pricePerTeam": 90000
        }
      ]
    }
  ]
}
```

## 2. Create a lobby

Endpoint:
`POST /matchmaking/lobbies`

Client call:
`createLobby(teamId, format, date, picks, ballType?)`

Payload:
```json
{
  "teamId": "team_123",
  "format": "T20",
  "ballType": "LEATHER",
  "date": "2026-05-06",
  "picks": [
    {
      "groundId": "unit_abc",
      "slotTime": "18:00"
    }
  ]
}
```

What it does:
- Creates the user’s matchmaking lobby request.
- This is the first write action in the Create flow.

Important:
- The backend does the same-slot comparison during lobby creation.
- Open-lobby discovery can still be used by the UI before or after create.

## 3. Load open lobbies

Endpoint:
`GET /matchmaking/lobbies`

Client call:
`listOpenLobbies(date?, format?)`

Query params:
```text
date=2026-05-06
format=T20
```

What it does:
- Returns open matchmaking lobbies for the requested day and format.
- This is the main source for same-slot rival detection.

Expected response shape:
```json
{
  "lobbies": [
    {
      "lobbyId": "lobby_1",
      "teamName": "Warriors",
      "ageGroup": "Open",
      "format": "T20",
      "groundName": "Swing Arena",
      "slotTime": "18:00",
      "date": "2026-05-06",
      "daysFromNow": 0,
      "isArenaLobby": false,
      "arenaName": "",
      "ballType": "LEATHER",
      "unitId": "unit_abc",
      "pricePerTeam": 90000
    }
  ]
}
```

## 4. Same-slot matching logic

This is client-side logic in `_SearchingFind`.

The app marks a lobby as a direct same-slot match when all of these are true:
- lobby has a `unitId`
- user pick has a `unitId`
- `pick.unitId == lobby.unitId`
- `pick.slotTime == lobby.slotTime`
- date and format are already the same because the query uses the same `date` and `format`

What this means:
- If the backend returns the slot identity under a different field name, the UI can miss it.
- If the time string format differs, the match will not surface.

## 5. Join an existing lobby

Endpoint:
`POST /matchmaking/lobbies/{lobbyId}/join`

Client call:
`joinLobby(lobbyId, teamId)`

Payload:
```json
{
  "teamId": "team_123"
}
```

What it does:
- Joins an open lobby created by another team.
- Used from the Discover/open-lobby flow.

## 6. Check lobby status

Endpoint:
`GET /matchmaking/lobbies/{lobbyId}`

Client call:
`getLobbyStatus(lobbyId)`

What it does:
- Polls the current lobby state after create/join.
- Used while the page is in `searching`, `matched`, or `waitingOpponent`.

Expected statuses:
- `matched`
- `confirmed`
- `expired`
- `cancelled`

## 7. Confirm a match

Endpoint:
`POST /matchmaking/matches/{matchId}/confirm`

Client call:
`confirmMatch(matchId, lobbyId)`

Payload:
```json
{
  "lobbyId": "lobby_123"
}
```

What it does:
- Confirms the matchup.
- Can move the UI into `waitingOpponent` if the other side is not fully confirmed yet.

## 8. Decline a match

Endpoint:
`POST /matchmaking/matches/{matchId}/decline`

Client call:
`declineMatch(matchId, lobbyId)`

Payload:
```json
{
  "lobbyId": "lobby_123"
}
```

What it does:
- Rejects the matchup and clears the current lobby state.

## 9. Restore the active lobby

Endpoint:
`GET /matchmaking/lobbies/active`

Client call:
`getActiveLobby()`

What it does:
- Restores the current in-progress lobby if the app is reopened.
- Lets the user resume a searching or waiting state.

## 10. App flow summary

1. User chooses team, format, date, and slots.
2. App calls `POST /matchmaking/lobbies`.
3. If the backend responds with `matched`, the UI jumps directly to the matched state.
4. Otherwise the UI goes to `searching`.
5. The app polls `GET /matchmaking/lobbies/{id}`.
6. The app also loads `GET /matchmaking/lobbies?date&format` and checks for same-slot rivals.
7. If a direct same-slot lobby is found, it shows the match-found card.
8. User confirms via `POST /matchmaking/matches/{matchId}/confirm`.
9. Payment and verification happen after confirmation.

## Identity rule to watch

The current client depends on `unitId` and exact `slotTime` matching.

If the backend returns the slot identifier under a different key, such as:
- `groundId`
- `arenaId`
- `slotId`

then same-slot detection can fail even if the lobby is actually present.

The backend now shares one age-group compatibility rule across create and open-lobby listing:
- explicit and equal age groups match
- if either side has no age group, the matchup is allowed
- explicit and different age groups do not match
