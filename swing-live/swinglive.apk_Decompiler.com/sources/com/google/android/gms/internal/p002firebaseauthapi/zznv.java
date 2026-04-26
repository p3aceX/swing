package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class zznv {
    private static final zznv zza = (zznv) zzpe.zza(new zzph() { // from class: com.google.android.gms.internal.firebase-auth-api.zznu
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzph
        public final Object zza() {
            zznv zznvVar = new zznv();
            zznvVar.zza(zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zznx
                @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
                public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                    return ((zznc) zzbuVar).zza(zzctVar);
                }
            }, zznc.class, zzot.class));
            return zznvVar;
        }
    });
    private final AtomicReference<zzoz> zzb = new AtomicReference<>(new zzoy().zza());

    public final <SerializationT extends zzow> zzbu zza(SerializationT serializationt, zzct zzctVar) {
        return this.zzb.get().zza(serializationt, zzctVar);
    }

    public final <SerializationT extends zzow> boolean zzb(SerializationT serializationt) {
        return this.zzb.get().zzc(serializationt);
    }

    public final zzbu zza(zzot zzotVar, zzct zzctVar) {
        return !this.zzb.get().zzb(zzotVar) ? new zznc(zzotVar, zzctVar) : zza(zzotVar, zzctVar);
    }

    public final <SerializationT extends zzow> zzci zza(SerializationT serializationt) {
        return this.zzb.get().zza(serializationt);
    }

    public static zznv zza() {
        return zza;
    }

    public final <KeyT extends zzbu, SerializationT extends zzow> SerializationT zza(KeyT keyt, Class<SerializationT> cls, zzct zzctVar) {
        return (SerializationT) this.zzb.get().zza(keyt, cls, zzctVar);
    }

    public final <ParametersT extends zzci, SerializationT extends zzow> SerializationT zza(ParametersT parameterst, Class<SerializationT> cls) {
        return (SerializationT) this.zzb.get().zza(parameterst, cls);
    }

    public final synchronized <SerializationT extends zzow> void zza(zzmt<SerializationT> zzmtVar) {
        this.zzb.set(new zzoy(this.zzb.get()).zza(zzmtVar).zza());
    }

    public final synchronized <KeyT extends zzbu, SerializationT extends zzow> void zza(zzmx<KeyT, SerializationT> zzmxVar) {
        this.zzb.set(new zzoy(this.zzb.get()).zza(zzmxVar).zza());
    }

    public final synchronized <SerializationT extends zzow> void zza(zznw<SerializationT> zznwVar) {
        this.zzb.set(new zzoy(this.zzb.get()).zza(zznwVar).zza());
    }

    public final synchronized <ParametersT extends zzci, SerializationT extends zzow> void zza(zzoa<ParametersT, SerializationT> zzoaVar) {
        this.zzb.set(new zzoy(this.zzb.get()).zza(zzoaVar).zza());
    }
}
