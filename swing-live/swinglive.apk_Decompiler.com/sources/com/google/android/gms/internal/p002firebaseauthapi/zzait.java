package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzait {
    private static final zzair<?> zza = new zzaiq();
    private static final zzair<?> zzb = zzc();

    public static zzair<?> zza() {
        zzair<?> zzairVar = zzb;
        if (zzairVar != null) {
            return zzairVar;
        }
        throw new IllegalStateException("Protobuf runtime is not correctly loaded.");
    }

    public static zzair<?> zzb() {
        return zza;
    }

    private static zzair<?> zzc() {
        try {
            return (zzair) Class.forName("com.google.protobuf.ExtensionSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            return null;
        }
    }
}
