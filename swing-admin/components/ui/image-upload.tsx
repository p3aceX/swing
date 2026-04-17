"use client";

import { useRef, useState } from "react";
import {
  isSupabaseConfigured,
  uploadFile,
  type UploadFolder,
} from "@/lib/supabase";

interface ImageUploadProps {
  folder: UploadFolder;
  id: string;
  filename: string;
  currentUrl?: string | null;
  onUpload: (url: string) => void;
  label?: string;
  shape?: "square" | "circle";
  size?: "sm" | "md" | "lg";
}

const sizeMap = { sm: "w-16 h-16", md: "w-24 h-24", lg: "w-32 h-32" };

export function ImageUpload({
  folder,
  id,
  filename,
  currentUrl,
  onUpload,
  label = "Upload Image",
  shape = "square",
  size = "md",
}: ImageUploadProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);
  const [preview, setPreview] = useState<string | null>(currentUrl ?? null);
  const [error, setError] = useState<string | null>(null);

  async function handleFile(file: File) {
    if (!isSupabaseConfigured) {
      setError(
        "Image uploads are disabled until Supabase env vars are configured.",
      );
      return;
    }
    if (!file.type.startsWith("image/")) {
      setError("Only image files allowed");
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      setError("Max file size is 5MB");
      return;
    }
    setError(null);
    setUploading(true);
    try {
      const url = await uploadFile(folder, id, filename, file);
      setPreview(url);
      onUpload(url);
    } catch (e: any) {
      setError(e.message ?? "Upload failed");
    } finally {
      setUploading(false);
    }
  }

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) handleFile(file);
  }

  function handleDrop(e: React.DragEvent) {
    e.preventDefault();
    const file = e.dataTransfer.files?.[0];
    if (file) handleFile(file);
  }

  const radiusCls = shape === "circle" ? "rounded-full" : "rounded-lg";
  const sizeCls = sizeMap[size];

  return (
    <div className="flex flex-col items-start gap-2">
      <div
        className={`${sizeCls} ${radiusCls} border-2 border-dashed border-border/60 overflow-hidden bg-muted/30 flex items-center justify-center relative transition-colors ${isSupabaseConfigured ? "hover:border-primary/50 cursor-pointer" : "cursor-not-allowed opacity-70"}`}
        onClick={() => {
          if (isSupabaseConfigured) inputRef.current?.click();
        }}
        onDragOver={(e) => e.preventDefault()}
        onDrop={handleDrop}
      >
        {preview ? (
          <img
            src={preview}
            alt="preview"
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="flex flex-col items-center gap-1 text-muted-foreground px-2 text-center">
            <span className="text-2xl">📷</span>
            <span className="text-[10px]">{label}</span>
          </div>
        )}
        {uploading && (
          <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
          </div>
        )}
      </div>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={handleChange}
      />
      {preview && (
        <button
          type="button"
          className="text-[11px] text-muted-foreground hover:text-destructive underline"
          onClick={() => {
            setPreview(null);
            onUpload("");
          }}
        >
          Remove
        </button>
      )}
      {error && <p className="text-[11px] text-destructive">{error}</p>}
      {!isSupabaseConfigured && !error && (
        <p className="text-[11px] text-muted-foreground">
          Set Supabase env vars to enable uploads.
        </p>
      )}
    </div>
  );
}
