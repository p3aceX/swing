package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzxr {
    private final byte[] zza;

    private zzxr(byte[] bArr, int i4, int i5) {
        byte[] bArr2 = new byte[i5];
        this.zza = bArr2;
        System.arraycopy(bArr, 0, bArr2, 0, i5);
    }

    public final boolean equals(Object obj) {
        if (obj instanceof zzxr) {
            return Arrays.equals(((zzxr) obj).zza, this.zza);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(this.zza);
    }

    public final String toString() {
        return S.g("Bytes(", zzxh.zza(this.zza), ")");
    }

    public final int zza() {
        return this.zza.length;
    }

    public final byte[] zzb() {
        byte[] bArr = this.zza;
        byte[] bArr2 = new byte[bArr.length];
        System.arraycopy(bArr, 0, bArr2, 0, bArr.length);
        return bArr2;
    }

    public static zzxr zza(byte[] bArr) {
        if (bArr == null) {
            throw new NullPointerException("data must be non-null");
        }
        int length = bArr.length;
        if (length > bArr.length) {
            length = bArr.length;
        }
        return new zzxr(bArr, 0, length);
    }
}
