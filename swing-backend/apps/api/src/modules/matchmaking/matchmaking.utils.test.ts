import assert from 'node:assert/strict'
import test from 'node:test'
import { areAgeGroupsCompatible } from './matchmaking.utils'

test('age groups are compatible when either side is unspecified', () => {
  assert.equal(areAgeGroupsCompatible(null, null), true)
  assert.equal(areAgeGroupsCompatible(null, 'U19'), true)
  assert.equal(areAgeGroupsCompatible('SENIOR', null), true)
})

test('age groups only block when both sides are explicit and different', () => {
  assert.equal(areAgeGroupsCompatible('U16', 'U16'), true)
  assert.equal(areAgeGroupsCompatible('U19', 'SENIOR'), false)
})
