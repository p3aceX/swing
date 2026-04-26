package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class zzno {
    private static final zzno zza = new zzno();
    private static final zznr zzb = new zznr();
    private final AtomicReference<zzrq> zzc = new AtomicReference<>();

    public static zzno zza() {
        return zza;
    }

    public final zzrq zzb() {
        zzrq zzrqVar = this.zzc.get();
        return zzrqVar == null ? zzb : zzrqVar;
    }
}
