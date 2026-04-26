package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzakd implements zzakl {
    private zzakl[] zza;

    public zzakd(zzakl... zzaklVarArr) {
        this.zza = zzaklVarArr;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakl
    public final zzaki zza(Class<?> cls) {
        for (zzakl zzaklVar : this.zza) {
            if (zzaklVar.zzb(cls)) {
                return zzaklVar.zza(cls);
            }
        }
        throw new UnsupportedOperationException("No factory is available for message type: ".concat(cls.getName()));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakl
    public final boolean zzb(Class<?> cls) {
        for (zzakl zzaklVar : this.zza) {
            if (zzaklVar.zzb(cls)) {
                return true;
            }
        }
        return false;
    }
}
