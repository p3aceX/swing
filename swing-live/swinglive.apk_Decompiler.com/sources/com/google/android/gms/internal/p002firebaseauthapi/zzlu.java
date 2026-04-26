package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
final class zzlu implements zzli {
    private final zzxr zza;
    private final zzxr zzb;

    private zzlu(byte[] bArr, byte[] bArr2) {
        this.zza = zzxr.zza(bArr);
        this.zzb = zzxr.zza(bArr2);
    }

    public static zzlu zza(byte[] bArr, byte[] bArr2, zzwq zzwqVar) throws GeneralSecurityException {
        zzwn.zza(zzwn.zza(zzwqVar, zzwp.UNCOMPRESSED, bArr2), zzwn.zza(zzwqVar, bArr));
        return new zzlu(bArr, bArr2);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzli
    public final zzxr zzb() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzli
    public final zzxr zza() {
        return this.zza;
    }
}
