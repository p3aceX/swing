package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
public final class zzxt {
    private final zzxr zza;

    private zzxt(zzxr zzxrVar) {
        this.zza = zzxrVar;
    }

    public final int zza() {
        return this.zza.zza();
    }

    public static zzxt zza(byte[] bArr, zzct zzctVar) {
        if (zzctVar != null) {
            return new zzxt(zzxr.zza(bArr));
        }
        throw new NullPointerException("SecretKeyAccess required");
    }

    public static zzxt zza(int i4) {
        return new zzxt(zzxr.zza(zzov.zza(i4)));
    }

    public final byte[] zza(zzct zzctVar) {
        if (zzctVar != null) {
            return this.zza.zzb();
        }
        throw new NullPointerException("SecretKeyAccess required");
    }
}
