package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzlw implements zzli {
    private final zzxr zza;
    private final zzxr zzb;

    private zzlw(byte[] bArr, byte[] bArr2) {
        this.zza = zzxr.zza(bArr);
        this.zzb = zzxr.zza(bArr2);
    }

    public static zzlw zza(byte[] bArr) {
        return new zzlw(bArr, zzxp.zza(bArr));
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
