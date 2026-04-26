package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
public final class zzdr implements zzdd {
    public static final zzdr zza = new zzdr();

    private zzdr() {
    }

    @Override // com.google.android.recaptcha.internal.zzdd
    public final void zza(int i4, zzcj zzcjVar, zzpq... zzpqVarArr) throws zzae {
        if (zzpqVarArr.length != 1) {
            throw new zzae(4, 3, null);
        }
        zzcjVar.zzc().zzf(i4, zzcjVar.zzc().zza(zzpqVarArr[0]));
    }
}
