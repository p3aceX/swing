import crypto from 'crypto'
import path from 'path'

import { createClient } from '@supabase/supabase-js'
import { FastifyInstance } from 'fastify'

import { AppError } from '../../lib/errors'

const DEFAULT_BUCKET = process.env.SUPABASE_STORAGE_BUCKET || 'swing-media'
const STORAGE_UPLOAD_TIMEOUT_MS = 25_000

function getSupabaseClient() {
  const supabaseUrl = process.env.SUPABASE_URL?.trim() || ''
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY?.trim() || ''

  if (!supabaseUrl || !serviceRoleKey) {
    throw new AppError(
      'STORAGE_NOT_CONFIGURED',
      'File upload is not configured on the backend',
      500,
    )
  }

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
}

function slugify(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60) || 'file'
}

function normalizeFolder(value: string) {
  return value
    .trim()
    .replace(/^\/+|\/+$/g, '')
    .replace(/\.\.+/g, '.')
    .replace(/[^a-zA-Z0-9/_-]/g, '-')
    .replace(/\/{2,}/g, '/')
}

async function withTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number,
  message: string,
) {
  let timeout: NodeJS.Timeout | undefined
  const timeoutPromise = new Promise<never>((_, reject) => {
    timeout = setTimeout(() => reject(new Error(message)), timeoutMs)
  })

  try {
    return await Promise.race([promise, timeoutPromise])
  } finally {
    if (timeout) clearTimeout(timeout)
  }
}

export async function mediaRoutes(app: FastifyInstance) {
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/media/upload', auth, async (request, reply) => {
    const startedAt = Date.now()
    const supabase = getSupabaseClient()
    let fileInfo: { filename: string; mimetype: string; buffer: Buffer } | null = null
    let folder = 'uploads'
    request.log.info({ route: '/media/upload' }, 'media upload started')

    for await (const part of request.parts()) {
      if (part.type === 'file' && part.fieldname === 'file') {
        request.log.info(
          { filename: part.filename, mimetype: part.mimetype },
          'media upload received file part',
        )
        const buffer = await part.toBuffer()
        fileInfo = {
          filename: part.filename,
          mimetype: part.mimetype,
          buffer,
        }
        request.log.info(
          { filename: part.filename, bytes: buffer.length, elapsedMs: Date.now() - startedAt },
          'media upload buffered file',
        )
      } else if (part.type === 'field' && part.fieldname === 'folder') {
        folder = String(part.value || folder)
        request.log.info({ folder }, 'media upload received folder field')
      }
    }

    if (!fileInfo) {
      throw new AppError('FILE_REQUIRED', 'A file is required for upload', 400)
    }

    const { filename, mimetype, buffer } = fileInfo
    if (buffer.length === 0) {
      throw new AppError('EMPTY_FILE', 'Upload file cannot be empty', 400)
    }

    const safeFolder = normalizeFolder(folder || 'uploads') || 'uploads'
    const parsed = path.parse(filename || 'upload')
    const baseName = slugify(parsed.name)
    const ext = parsed.ext ? parsed.ext.toLowerCase() : ''
    const objectPath = `${safeFolder}/${crypto.randomUUID()}-${baseName}${ext}`

    request.log.info({ bucket: DEFAULT_BUCKET, objectPath }, 'media upload sending to storage')
    const upload = await withTimeout(
      supabase.storage
        .from(DEFAULT_BUCKET)
        .upload(objectPath, buffer, {
          contentType: mimetype,
          upsert: false,
        }),
      STORAGE_UPLOAD_TIMEOUT_MS,
      'Supabase storage upload timed out',
    ).catch((error) => {
      request.log.error(
        { err: error, bucket: DEFAULT_BUCKET, objectPath, elapsedMs: Date.now() - startedAt },
        'media upload storage request failed',
      )
      throw new AppError(
        'UPLOAD_TIMEOUT',
        'File storage did not respond in time. Please try again.',
        504,
      )
    })

    if (upload.error) {
      request.log.error(
        { error: upload.error, bucket: DEFAULT_BUCKET, objectPath, elapsedMs: Date.now() - startedAt },
        'media upload storage rejected file',
      )
      throw new AppError('UPLOAD_FAILED', upload.error.message, 500)
    }

    const { data } = supabase.storage.from(DEFAULT_BUCKET).getPublicUrl(objectPath)
    request.log.info(
      { bucket: DEFAULT_BUCKET, objectPath, elapsedMs: Date.now() - startedAt },
      'media upload finished',
    )

    return reply.code(201).send({
      success: true,
      data: {
        bucket: DEFAULT_BUCKET,
        path: upload.data.path,
        publicUrl: data.publicUrl,
      },
    })
  })
}
