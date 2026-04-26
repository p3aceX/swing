package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzaio {
    private final Object zza;
    private final int zzb;

    public zzaio(Object obj, int i4) {
        this.zza = obj;
        this.zzb = i4;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzaio)) {
            return false;
        }
        zzaio zzaioVar = (zzaio) obj;
        return this.zza == zzaioVar.zza && this.zzb == zzaioVar.zzb;
    }

    public final int hashCode() {
        return (System.identityHashCode(this.zza) * 65535) + this.zzb;
    }
}
