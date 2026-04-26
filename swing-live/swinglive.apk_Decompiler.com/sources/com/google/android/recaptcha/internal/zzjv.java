package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
final class zzjv implements zzkc {
    private final zzkc[] zza;

    public zzjv(zzkc... zzkcVarArr) {
        this.zza = zzkcVarArr;
    }

    @Override // com.google.android.recaptcha.internal.zzkc
    public final zzkb zzb(Class cls) {
        for (int i4 = 0; i4 < 2; i4++) {
            zzkc zzkcVar = this.zza[i4];
            if (zzkcVar.zzc(cls)) {
                return zzkcVar.zzb(cls);
            }
        }
        throw new UnsupportedOperationException("No factory is available for message type: ".concat(cls.getName()));
    }

    @Override // com.google.android.recaptcha.internal.zzkc
    public final boolean zzc(Class cls) {
        for (int i4 = 0; i4 < 2; i4++) {
            if (this.zza[i4].zzc(cls)) {
                return true;
            }
        }
        return false;
    }
}
