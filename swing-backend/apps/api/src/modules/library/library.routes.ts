import { FastifyInstance } from 'fastify'
import { drillRoutes } from './drill.routes'
import { fitnessRoutes } from './fitness.routes'
import { nutritionRoutes } from './nutrition.routes'

export async function libraryRoutes(app: FastifyInstance) {
  await app.register(drillRoutes, { prefix: '/drills' })
  await app.register(fitnessRoutes, { prefix: '/fitness-exercises' })
  // Nutrition routes define their own sub-paths (nutrition-items + nutrition-recipes)
  await app.register(nutritionRoutes)
}
