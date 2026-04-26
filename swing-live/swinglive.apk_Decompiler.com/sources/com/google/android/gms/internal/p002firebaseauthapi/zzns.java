package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class zzns {
    private static zzns zza = new zzns();
    private final AtomicReference<zzol> zzb = new AtomicReference<>(new zzok().zza());

    public static zzns zza() {
        return zza;
    }

    public final <WrapperPrimitiveT> Class<?> zza(Class<WrapperPrimitiveT> cls) {
        return this.zzb.get().zza((Class<?>) cls);
    }

    public final <KeyT extends zzbu, PrimitiveT> PrimitiveT zza(KeyT keyt, Class<PrimitiveT> cls) {
        return (PrimitiveT) this.zzb.get().zza(keyt, cls);
    }

    public final <InputPrimitiveT, WrapperPrimitiveT> WrapperPrimitiveT zza(zzch<InputPrimitiveT> zzchVar, Class<WrapperPrimitiveT> cls) {
        return (WrapperPrimitiveT) this.zzb.get().zza(zzchVar, cls);
    }

    public final synchronized <KeyT extends zzbu, PrimitiveT> void zza(zzoe<KeyT, PrimitiveT> zzoeVar) {
        this.zzb.set(zzol.zza(this.zzb.get()).zza(zzoeVar).zza());
    }

    public final synchronized <InputPrimitiveT, WrapperPrimitiveT> void zza(zzcq<InputPrimitiveT, WrapperPrimitiveT> zzcqVar) {
        this.zzb.set(zzol.zza(this.zzb.get()).zza(zzcqVar).zza());
    }
}
