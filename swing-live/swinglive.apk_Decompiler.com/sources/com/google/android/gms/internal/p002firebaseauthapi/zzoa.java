package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzci;
import com.google.android.gms.internal.p002firebaseauthapi.zzow;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzoa<ParametersT extends zzci, SerializationT extends zzow> {
    private final Class<ParametersT> zza;
    private final Class<SerializationT> zzb;

    public static <ParametersT extends zzci, SerializationT extends zzow> zzoa<ParametersT, SerializationT> zza(zzoc<ParametersT, SerializationT> zzocVar, Class<ParametersT> cls, Class<SerializationT> cls2) {
        return new zzod(cls, cls2, zzocVar);
    }

    public abstract SerializationT zza(ParametersT parameterst);

    public final Class<SerializationT> zzb() {
        return this.zzb;
    }

    private zzoa(Class<ParametersT> cls, Class<SerializationT> cls2) {
        this.zza = cls;
        this.zzb = cls2;
    }

    public final Class<ParametersT> zza() {
        return this.zza;
    }
}
