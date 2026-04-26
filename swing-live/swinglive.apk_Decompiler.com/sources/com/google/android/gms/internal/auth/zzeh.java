package com.google.android.gms.internal.auth;

import com.google.android.gms.common.api.f;

/* JADX INFO: loaded from: classes.dex */
final class zzeh extends zzej {
    private final byte[] zzb;
    private int zzc;
    private int zzd;
    private int zze;

    public /* synthetic */ zzeh(byte[] bArr, int i4, int i5, boolean z4, zzeg zzegVar) {
        super(null);
        this.zze = f.API_PRIORITY_OTHER;
        this.zzb = bArr;
        this.zzc = 0;
    }

    public final int zza(int i4) {
        int i5 = this.zze;
        this.zze = 0;
        int i6 = this.zzc + this.zzd;
        this.zzc = i6;
        if (i6 <= 0) {
            this.zzd = 0;
            return i5;
        }
        this.zzd = i6;
        this.zzc = 0;
        return i5;
    }
}
