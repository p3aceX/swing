import crypto from 'crypto'
import path from 'path'

import { createClient } from '@supabase/supabase-js'
import { FastifyInstance } from 'fastify'

import { AppError } from '../../lib/errors'

const DEFAULT_BUCKET = process.env.SUPABASE_STORAGE_BUCKET || 'swing-media'

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

export async function mediaRoutes(app: FastifyInstance) {
  const auth = { onRequest: [(app as any).authenticate] }

  app.post('/media/upload', auth, async (request, reply) => {
    const supabase = getSupabaseClient()
    let filePart: any = null
    let folder = 'uploads'

    for await (const part of request.parts()) {
      if (part.type === 'file' && part.fieldname === 'file') {
        filePart = part
      } else if (part.type === 'field' && part.fieldname === 'folder') {
        folder = String(part.value || folder)
      }
    }

    if (!filePart) {
      throw new AppError('FILE_REQUIRED', 'A file is required for upload', 400)
    }

    const buffer = await filePart.toBuffer()
    if (buffer.length === 0) {
      throw new AppError('EMPTY_FILE', 'Upload file cannot be empty', 400)
    }

    const safeFolder = normalizeFolder(folder || 'uploads') || 'uploads'
    const parsed = path.parse(filePart.filename || 'upload')
    const baseName = slugify(parsed.name)
    const ext = parsed.ext ? parsed.ext.toLowerCase() : ''
    const objectPath = `${safeFolder}/${crypto.randomUUID()}-${baseName}${ext}`

    const upload = await supabase.storage
      .from(DEFAULT_BUCKET)
      .upload(objectPath, buffer, {
        upsert: false,
      })

    if (upload.error) {
      throw new AppError('UPLOAD_FAILED', upload.error.message, 500)
    }

    const { data } = supabase.storage.from(DEFAULT_BUCKET).getPublicUrl(objectPath)

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
