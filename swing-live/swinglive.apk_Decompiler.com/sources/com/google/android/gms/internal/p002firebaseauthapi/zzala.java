package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzala implements zzaki {
    private final zzakk zza;
    private final String zzb;
    private final Object[] zzc;
    private final int zzd;

    public zzala(zzakk zzakkVar, String str, Object[] objArr) {
        this.zza = zzakkVar;
        this.zzb = str;
        this.zzc = objArr;
        char cCharAt = str.charAt(0);
        if (cCharAt < 55296) {
            this.zzd = cCharAt;
            return;
        }
        int i4 = cCharAt & 8191;
        int i5 = 13;
        int i6 = 1;
        while (true) {
            int i7 = i6 + 1;
            char cCharAt2 = str.charAt(i6);
            if (cCharAt2 < 55296) {
                this.zzd = i4 | (cCharAt2 << i5);
                return;
            } else {
                i4 |= (cCharAt2 & 8191) << i5;
                i5 += 13;
                i6 = i7;
            }
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaki
    public final zzakk zza() {
        return this.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaki
    public final zzakz zzb() {
        int i4 = this.zzd;
        return (i4 & 1) != 0 ? zzakz.PROTO2 : (i4 & 4) == 4 ? zzakz.EDITIONS : zzakz.PROTO3;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaki
    public final boolean zzc() {
        return (this.zzd & 2) == 2;
    }

    public final String zzd() {
        return this.zzb;
    }

    public final Object[] zze() {
        return this.zzc;
    }
}
