package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
abstract class zzajt {
    private static final zzajt zza = new zzajs();
    private static final zzajt zzb = new zzaju();

    private zzajt() {
    }

    public static zzajt zza() {
        return zza;
    }

    public static zzajt zzb() {
        return zzb;
    }

    public abstract <L> List<L> zza(Object obj, long j4);

    public abstract <L> void zza(Object obj, Object obj2, long j4);

    public abstract void zzb(Object obj, long j4);
}
