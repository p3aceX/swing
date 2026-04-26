package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzaja;

/* JADX INFO: loaded from: classes.dex */
final class zzajb implements zzakl {
    private static final zzajb zza = new zzajb();

    private zzajb() {
    }

    public static zzajb zza() {
        return zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakl
    public final boolean zzb(Class<?> cls) {
        return zzaja.class.isAssignableFrom(cls);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzakl
    public final zzaki zza(Class<?> cls) {
        if (!zzaja.class.isAssignableFrom(cls)) {
            throw new IllegalArgumentException("Unsupported message type: ".concat(cls.getName()));
        }
        try {
            return (zzaki) zzaja.zza(cls.asSubclass(zzaja.class)).zza(zzaja.zze.zzc, (Object) null, (Object) null);
        } catch (Exception e) {
            throw new RuntimeException("Unable to get message info for ".concat(cls.getName()), e);
        }
    }
}
