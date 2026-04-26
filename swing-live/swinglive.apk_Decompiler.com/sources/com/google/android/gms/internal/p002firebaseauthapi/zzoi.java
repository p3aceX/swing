package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzakk;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzoi<PrimitiveT, KeyProtoT extends zzakk> {
    private final Class<PrimitiveT> zza;

    public zzoi(Class<PrimitiveT> cls) {
        this.zza = cls;
    }

    public final Class<PrimitiveT> zza() {
        return this.zza;
    }

    public abstract PrimitiveT zza(KeyProtoT keyprotot);
}
