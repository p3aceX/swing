export function areAgeGroupsCompatible(callerAge: string | null, lobbyAge: string | null) {
  return callerAge == null || lobbyAge == null || callerAge === lobbyAge
}
