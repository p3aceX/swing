package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzaku {
    private static final zzaks zza = zzc();
    private static final zzaks zzb = new zzakv();

    public static zzaks zza() {
        return zza;
    }

    public static zzaks zzb() {
        return zzb;
    }

    private static zzaks zzc() {
        try {
            return (zzaks) Class.forName("com.google.protobuf.NewInstanceSchemaFull").getDeclaredConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Exception unused) {
            return null;
        }
    }
}
