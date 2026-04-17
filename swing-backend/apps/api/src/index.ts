import { buildApp } from './app'
import { validateRuntimeEnv } from './lib/env'
import { startAllWorkers } from './workers'

const PORT = Number(process.env.PORT) || 3000
const HOST = process.env.HOST || '0.0.0.0'
const START_WORKERS =
  process.env.START_WORKERS === 'true' ||
  (process.env.START_WORKERS !== 'false' && process.env.NODE_ENV !== 'production')

async function main() {
  validateRuntimeEnv('api')

  if (START_WORKERS) {
    await startAllWorkers()
  }

  const app = await buildApp()

  try {
    await app.listen({ port: PORT, host: HOST })
    app.log.info(`Swing API running at http://${HOST}:${PORT}`)
    app.log.info(`Swagger docs at http://${HOST}:${PORT}/docs`)
    if (START_WORKERS) {
      app.log.info('BullMQ workers running in this process')
    } else {
      app.log.info('BullMQ workers disabled for this process')
    }
  } catch (err) {
    app.log.error(err)
    process.exit(1)
  }
}

main()
