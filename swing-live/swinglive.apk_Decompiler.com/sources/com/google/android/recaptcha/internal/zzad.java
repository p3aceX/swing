package com.google.android.recaptcha.internal;

import F3.a;
import J3.i;
import a.AbstractC0184a;
import android.content.Context;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.Arrays;
import x3.AbstractC0726f;

/* JADX INFO: loaded from: classes.dex */
public final class zzad {
    private final Context zza;

    public zzad(Context context) {
        this.zza = context;
    }

    public static final byte[] zza(File file) throws IllegalAccessException, IOException, InvocationTargetException {
        i.e(file, "<this>");
        FileInputStream fileInputStream = new FileInputStream(file);
        try {
            long length = file.length();
            if (length > 2147483647L) {
                throw new OutOfMemoryError("File " + file + " is too big (" + length + " bytes) to fit in memory.");
            }
            int i4 = (int) length;
            byte[] bArrCopyOf = new byte[i4];
            int i5 = i4;
            int i6 = 0;
            while (i5 > 0) {
                int i7 = fileInputStream.read(bArrCopyOf, i6, i5);
                if (i7 < 0) {
                    break;
                }
                i5 -= i7;
                i6 += i7;
            }
            if (i5 > 0) {
                bArrCopyOf = Arrays.copyOf(bArrCopyOf, i6);
                i.d(bArrCopyOf, "copyOf(...)");
            } else {
                int i8 = fileInputStream.read();
                if (i8 != -1) {
                    a aVar = new a(8193);
                    aVar.write(i8);
                    AbstractC0184a.m(fileInputStream, aVar);
                    int size = aVar.size() + i4;
                    if (size < 0) {
                        throw new OutOfMemoryError("File " + file + " is too big to fit in memory.");
                    }
                    byte[] bArrB = aVar.b();
                    bArrCopyOf = Arrays.copyOf(bArrCopyOf, size);
                    i.d(bArrCopyOf, "copyOf(...)");
                    AbstractC0726f.d0(bArrB, i4, bArrCopyOf, 0, aVar.size());
                }
            }
            fileInputStream.close();
            return bArrCopyOf;
        } catch (Throwable th) {
            try {
                throw th;
            } catch (Throwable th2) {
                H0.a.d(fileInputStream, th);
                throw th2;
            }
        }
    }

    public static final void zzb(File file, byte[] bArr) throws IllegalAccessException, IOException, InvocationTargetException {
        if (file.exists() && !file.delete()) {
            throw new IOException("Unable to delete existing encrypted file");
        }
        i.e(bArr, "array");
        FileOutputStream fileOutputStream = new FileOutputStream(file);
        try {
            fileOutputStream.write(bArr);
            fileOutputStream.close();
        } finally {
        }
    }
}
