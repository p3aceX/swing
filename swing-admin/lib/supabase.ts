import { createClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? "";
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? "";
export const isSupabaseConfigured = Boolean(supabaseUrl && supabaseAnonKey);
let supabaseClient: ReturnType<typeof createClient> | null = null;

export const BUCKET = "swing-media";
export function getSupabaseClient() {
  if (!isSupabaseConfigured) {
    throw new Error(
      "Supabase storage is not configured. Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY.",
    );
  }

  if (!supabaseClient) {
    supabaseClient = createClient(supabaseUrl, supabaseAnonKey);
  }

  return supabaseClient;
}

export type UploadFolder =
  | "teams"
  | "tournaments"
  | "arenas"
  | "players"
  | "grounds"
  | "misc";

/**
 * Upload a file to Supabase Storage.
 * Returns the public URL of the uploaded file.
 */
export async function uploadFile(
  folder: UploadFolder,
  id: string,
  filename: string,
  file: File,
): Promise<string> {
  const supabase = getSupabaseClient();
  const ext = file.name.split(".").pop() ?? "jpg";
  const path = `${folder}/${id}/${filename}.${ext}`;

  const { error } = await supabase.storage
    .from(BUCKET)
    .upload(path, file, { upsert: true, contentType: file.type });

  if (error) throw new Error(error.message);

  const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);
  return data.publicUrl;
}
