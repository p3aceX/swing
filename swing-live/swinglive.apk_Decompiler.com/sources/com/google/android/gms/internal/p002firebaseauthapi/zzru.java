package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzru {
    private final zzbw zza;
    private final int zzb;
    private final String zzc;
    private final String zzd;

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzru)) {
            return false;
        }
        zzru zzruVar = (zzru) obj;
        return this.zza == zzruVar.zza && this.zzb == zzruVar.zzb && this.zzc.equals(zzruVar.zzc) && this.zzd.equals(zzruVar.zzd);
    }

    public final int hashCode() {
        return Objects.hash(this.zza, Integer.valueOf(this.zzb), this.zzc, this.zzd);
    }

    public final String toString() {
        return "(status=" + this.zza + ", keyId=" + this.zzb + ", keyType='" + this.zzc + "', keyPrefix='" + this.zzd + "')";
    }

    public final int zza() {
        return this.zzb;
    }

    private zzru(zzbw zzbwVar, int i4, String str, String str2) {
        this.zza = zzbwVar;
        this.zzb = i4;
        this.zzc = str;
        this.zzd = str2;
    }
}
