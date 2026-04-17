export interface JwtPayload {
  userId: string
  activeRole: string
  roles: string[]
  iat?: number
  exp?: number
}

export interface OtpRequest {
  phone: string
}

export interface OtpVerifyRequest {
  phone: string
  code: string
  name?: string
  language?: string
}

export interface AuthTokens {
  accessToken: string
  refreshToken: string
  expiresIn: number
}
