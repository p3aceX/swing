package com.google.android.gms.internal.auth;

import android.net.Uri;

/* JADX INFO: loaded from: classes.dex */
public final class zzcz {
    final Uri zza;
    final String zzb;
    final String zzc;
    final boolean zzd;
    final boolean zze;

    private zzcz(String str, Uri uri, String str2, String str3, boolean z4, boolean z5, boolean z6, boolean z7, zzdg zzdgVar) {
        this.zza = uri;
        this.zzb = "";
        this.zzc = "";
        this.zzd = z4;
        this.zze = z6;
    }

    public final zzcz zza() {
        return new zzcz(null, this.zza, this.zzb, this.zzc, this.zzd, false, true, false, null);
    }

    public final zzcz zzb() {
        if (this.zzb.isEmpty()) {
            return new zzcz(null, this.zza, this.zzb, this.zzc, true, false, this.zze, false, null);
        }
        throw new IllegalStateException("Cannot set GServices prefix and skip GServices");
    }

    public final zzdc zzc(String str, double d5) {
        return new zzcx(this, str, Double.valueOf(0.0d), true);
    }

    public final zzdc zzd(String str, long j4) {
        return new zzcv(this, str, Long.valueOf(j4), true);
    }

    public final zzdc zze(String str, boolean z4) {
        return new zzcw(this, str, Boolean.valueOf(z4), true);
    }

    public final zzdc zzf(String str, Object obj, zzhy zzhyVar) {
        return new zzcy(this, "getTokenRefactor__blocked_packages", obj, true, zzhyVar);
    }

    public zzcz(Uri uri) {
        this(null, uri, "", "", false, false, false, false, null);
    }
}
