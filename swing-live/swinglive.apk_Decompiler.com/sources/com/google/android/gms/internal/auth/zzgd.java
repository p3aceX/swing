package com.google.android.gms.internal.auth;

/* JADX INFO: loaded from: classes.dex */
final class zzgd {
    private static final zzgc zza;
    private static final zzgc zzb;

    static {
        zzgc zzgcVar;
        try {
            zzgcVar = (zzgc) Class.forName("com.google.protobuf.NewInstanceSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            zzgcVar = null;
        }
        zza = zzgcVar;
        zzb = new zzgc();
    }

    public static zzgc zza() {
        return zza;
    }

    public static zzgc zzb() {
        return zzb;
    }
}
