package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzow;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzmt<SerializationT extends zzow> {
    private final zzxr zza;
    private final Class<SerializationT> zzb;

    public static <SerializationT extends zzow> zzmt<SerializationT> zza(zzmv<SerializationT> zzmvVar, zzxr zzxrVar, Class<SerializationT> cls) {
        return new zzms(zzxrVar, cls, zzmvVar);
    }

    public abstract zzbu zza(SerializationT serializationt, zzct zzctVar);

    public final Class<SerializationT> zzb() {
        return this.zzb;
    }

    private zzmt(zzxr zzxrVar, Class<SerializationT> cls) {
        this.zza = zzxrVar;
        this.zzb = cls;
    }

    public final zzxr zza() {
        return this.zza;
    }
}
