import { test } from 'node:test'
import assert from 'node:assert'
import { StoreService } from './store.service'

test('StoreService initialization', () => {
  const svc = new StoreService()
  assert.ok(svc)
})
