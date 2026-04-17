"use client";

import { useRef, useState } from "react";
import { Plus, Trash2 } from "lucide-react";
import {
  isSupabaseConfigured,
  uploadFile,
  type UploadFolder,
} from "@/lib/supabase";
import { Button } from "@/components/ui/button";

type MultiImageUploadProps = {
  folder: UploadFolder;
  id: string;
  values: string[];
  onChange: (urls: string[]) => void;
  label?: string;
  hint?: string;
  disabled?: boolean;
};

export function MultiImageUpload({
  folder,
  id,
  values,
  onChange,
  label = "Upload images",
  hint,
  disabled = false,
}: MultiImageUploadProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleFiles(fileList: FileList | null) {
    const files = Array.from(fileList ?? []);
    if (files.length === 0 || disabled) return;

    if (!isSupabaseConfigured) {
      setError(
        "Image uploads are disabled until Supabase env vars are configured.",
      );
      return;
    }

    for (const file of files) {
      if (!file.type.startsWith("image/")) {
        setError("Only image files allowed");
        return;
      }
      if (file.size > 5 * 1024 * 1024) {
        setError("Max file size is 5MB per image");
        return;
      }
    }

    setError(null);
    setUploading(true);

    try {
      const uploadedUrls: string[] = [];
      for (const file of files) {
        const filename = `photo-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
        const url = await uploadFile(folder, id, filename, file);
        uploadedUrls.push(url);
      }
      onChange([...values, ...uploadedUrls]);
    } catch (e: any) {
      setError(e.message ?? "Upload failed");
    } finally {
      setUploading(false);
      if (inputRef.current) inputRef.current.value = "";
    }
  }

  function removeAt(index: number) {
    onChange(values.filter((_, currentIndex) => currentIndex !== index));
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between gap-3">
        <div>
          <div className="text-sm font-medium">{label}</div>
          {hint ? <p className="text-xs text-muted-foreground">{hint}</p> : null}
        </div>
        <Button
          type="button"
          variant="outline"
          disabled={disabled || uploading || !isSupabaseConfigured}
          onClick={() => inputRef.current?.click()}
        >
          <Plus className="mr-2 h-4 w-4" />
          {uploading ? "Uploading..." : "Add Photos"}
        </Button>
      </div>

      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        multiple
        className="hidden"
        onChange={(event) => handleFiles(event.target.files)}
      />

      {values.length === 0 ? (
        <div className="rounded-xl border border-dashed p-6 text-sm text-muted-foreground">
          No photos uploaded yet.
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3 md:grid-cols-3 xl:grid-cols-4">
          {values.map((url, index) => (
            <div key={`${url}-${index}`} className="group relative overflow-hidden rounded-xl border bg-muted/20">
              <img
                src={url}
                alt={`Arena photo ${index + 1}`}
                className="aspect-[4/3] w-full object-cover"
              />
              {!disabled ? (
                <button
                  type="button"
                  className="absolute right-2 top-2 inline-flex h-8 w-8 items-center justify-center rounded-full bg-black/60 text-white opacity-0 transition-opacity group-hover:opacity-100"
                  onClick={() => removeAt(index)}
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              ) : null}
            </div>
          ))}
        </div>
      )}

      {error ? <p className="text-xs text-destructive">{error}</p> : null}
      {!isSupabaseConfigured && !error ? (
        <p className="text-xs text-muted-foreground">
          Set Supabase env vars to enable uploads.
        </p>
      ) : null}
    </div>
  );
}
