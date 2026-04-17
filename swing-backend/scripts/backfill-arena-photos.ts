import { prisma } from '@swing/db'

async function main() {
  const imageUrl = 'https://pdlqotoyxpzrylxvrmdm.supabase.co/storage/v1/object/public/swing-media/arenas/cmnd808fw0005eqnnlk55lzl0/photos/photo_1774945069298.jpg'
  
  console.log('🖼  Backfilling Arena photoUrls...')

  // We use executeRawUnsafe to ensure the PostgreSQL array is set correctly 
  // for all records in one go.
  const count = await prisma.$executeRawUnsafe(
    'UPDATE "Arena" SET "photoUrls" = ARRAY[$1];',
    imageUrl
  )

  console.log(`✅ Successfully updated ${count} arenas with the new photo URL.`)
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
