package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zzol {
    private final Map<zzom, zzoe<?, ?>> zza;
    private final Map<Class<?>, zzcq<?, ?>> zzb;

    public static zzok zza(zzol zzolVar) {
        return new zzok(zzolVar);
    }

    private zzol(zzok zzokVar) {
        this.zza = new HashMap(zzokVar.zza);
        this.zzb = new HashMap(zzokVar.zzb);
    }

    public final Class<?> zza(Class<?> cls) throws GeneralSecurityException {
        if (this.zzb.containsKey(cls)) {
            return this.zzb.get(cls).zza();
        }
        throw new GeneralSecurityException(S.g("No input primitive class for ", String.valueOf(cls), " available"));
    }

    public final <KeyT extends zzbu, PrimitiveT> PrimitiveT zza(KeyT keyt, Class<PrimitiveT> cls) throws GeneralSecurityException {
        zzom zzomVar = new zzom(keyt.getClass(), cls);
        if (this.zza.containsKey(zzomVar)) {
            return (PrimitiveT) this.zza.get(zzomVar).zza(keyt);
        }
        throw new GeneralSecurityException(S.g("No PrimitiveConstructor for ", String.valueOf(zzomVar), " available"));
    }

    public final <InputPrimitiveT, WrapperPrimitiveT> WrapperPrimitiveT zza(zzch<InputPrimitiveT> zzchVar, Class<WrapperPrimitiveT> cls) throws GeneralSecurityException {
        if (this.zzb.containsKey(cls)) {
            zzcq<?, ?> zzcqVar = this.zzb.get(cls);
            if (zzchVar.zzc().equals(zzcqVar.zza()) && zzcqVar.zza().equals(zzchVar.zzc())) {
                return (WrapperPrimitiveT) zzcqVar.zza(zzchVar);
            }
            throw new GeneralSecurityException("Input primitive type of the wrapper doesn't match the type of primitives in the provided PrimitiveSet");
        }
        throw new GeneralSecurityException("No wrapper found for ".concat(String.valueOf(cls)));
    }
}
