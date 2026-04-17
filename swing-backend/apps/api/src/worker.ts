import http from 'http'

import { validateRuntimeEnv } from './lib/env'
import { startAllWorkers } from './workers'

const PORT = Number(process.env.PORT) || 3000
const HOST = process.env.HOST || '0.0.0.0'

async function main() {
  validateRuntimeEnv('worker')

  await startAllWorkers()

  const server = http.createServer((req, res) => {
    if (req.url === '/health') {
      res.writeHead(200, { 'content-type': 'application/json' })
      res.end(JSON.stringify({
        status: 'ok',
        service: 'worker',
        timestamp: new Date().toISOString(),
      }))
      return
    }

    res.writeHead(200, { 'content-type': 'text/plain' })
    res.end('Swing worker is running')
  })

  server.listen(PORT, HOST, () => {
    console.log(`[Worker] Listening on http://${HOST}:${PORT}/health`)
  })
}

main().catch((err) => {
  console.error('[Worker] Failed to start', err)
  process.exit(1)
})
