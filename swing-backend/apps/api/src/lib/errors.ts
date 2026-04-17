import { FastifyError, FastifyReply, FastifyRequest } from 'fastify'

export class AppError extends Error {
  constructor(
    public readonly code: string,
    public readonly message: string,
    public readonly statusCode: number = 400,
    public readonly details?: Record<string, unknown>,
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export function errorHandler(error: FastifyError | Error, request: FastifyRequest, reply: FastifyReply) {
  request.log.error(error)

  if (error instanceof AppError) {
    return reply.code(error.statusCode).send({
      success: false,
      error: { code: error.code, message: error.message, details: error.details },
    })
  }

  const fastifyErr = error as FastifyError
  if (fastifyErr.validation) {
    return reply.code(400).send({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'Invalid request data', details: fastifyErr.validation },
    })
  }

  if (fastifyErr.statusCode === 429) {
    return reply.code(429).send({
      success: false,
      error: { code: 'RATE_LIMITED', message: 'Too many requests' },
    })
  }

  // Zod parse errors bubble up as regular errors from route handlers
  if (error.name === 'ZodError') {
    return reply.code(400).send({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'Invalid request data', details: (error as any).errors },
    })
  }

  return reply.code(500).send({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' },
  })
}

export const Errors = {
  unauthorized: () => new AppError('UNAUTHORIZED', 'Authentication required', 401),
  forbidden: () => new AppError('FORBIDDEN', 'Insufficient permissions', 403),
  notFound: (resource: string) => new AppError('NOT_FOUND', `${resource} not found`, 404),
  otpExpired: () => new AppError('OTP_EXPIRED', 'OTP has expired. Please request a new one', 400),
  otpMaxAttempts: () => new AppError('OTP_MAX_ATTEMPTS', 'Too many wrong OTP attempts. Please request a new one', 429),
  otpRateLimit: () => new AppError('OTP_RATE_LIMIT', 'Please wait before requesting another OTP', 429),
  slotAlreadyBooked: () => new AppError('SLOT_ALREADY_BOOKED', 'This slot is no longer available', 409),
  paymentFailed: (reason?: string) => new AppError('PAYMENT_FAILED', reason || 'Payment failed', 402),
  matchmakingBanned: (until: Date) =>
    new AppError('MATCHMAKING_BANNED', `You are banned from matchmaking until ${until.toISOString()}`, 403),
  planLimitReached: () =>
    new AppError('PLAN_LIMIT_REACHED', 'You have reached the maximum students allowed on your plan', 403),
}
