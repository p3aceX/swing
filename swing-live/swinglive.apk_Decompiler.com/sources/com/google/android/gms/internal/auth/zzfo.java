package com.google.android.gms.internal.auth;

/* JADX INFO: loaded from: classes.dex */
final class zzfo implements zzfv {
    private final zzfv[] zza;

    public zzfo(zzfv... zzfvVarArr) {
        this.zza = zzfvVarArr;
    }

    @Override // com.google.android.gms.internal.auth.zzfv
    public final zzfu zzb(Class cls) {
        zzfv[] zzfvVarArr = this.zza;
        for (int i4 = 0; i4 < 2; i4++) {
            zzfv zzfvVar = zzfvVarArr[i4];
            if (zzfvVar.zzc(cls)) {
                return zzfvVar.zzb(cls);
            }
        }
        throw new UnsupportedOperationException("No factory is available for message type: ".concat(cls.getName()));
    }

    @Override // com.google.android.gms.internal.auth.zzfv
    public final boolean zzc(Class cls) {
        zzfv[] zzfvVarArr = this.zza;
        for (int i4 = 0; i4 < 2; i4++) {
            if (zzfvVarArr[i4].zzc(cls)) {
                return true;
            }
        }
        return false;
    }
}
