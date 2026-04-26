package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zzok {
    private final Map<zzom, zzoe<?, ?>> zza;
    private final Map<Class<?>, zzcq<?, ?>> zzb;

    public final <KeyT extends zzbu, PrimitiveT> zzok zza(zzoe<KeyT, PrimitiveT> zzoeVar) throws GeneralSecurityException {
        if (zzoeVar == null) {
            throw new NullPointerException("primitive constructor must be non-null");
        }
        zzom zzomVar = new zzom(zzoeVar.zza(), zzoeVar.zzb());
        if (!this.zza.containsKey(zzomVar)) {
            this.zza.put(zzomVar, zzoeVar);
            return this;
        }
        zzoe<?, ?> zzoeVar2 = this.zza.get(zzomVar);
        if (zzoeVar2.equals(zzoeVar) && zzoeVar.equals(zzoeVar2)) {
            return this;
        }
        throw new GeneralSecurityException("Attempt to register non-equal PrimitiveConstructor object for already existing object of type: ".concat(String.valueOf(zzomVar)));
    }

    private zzok() {
        this.zza = new HashMap();
        this.zzb = new HashMap();
    }

    private zzok(zzol zzolVar) {
        this.zza = new HashMap(zzolVar.zza);
        this.zzb = new HashMap(zzolVar.zzb);
    }

    public final <InputPrimitiveT, WrapperPrimitiveT> zzok zza(zzcq<InputPrimitiveT, WrapperPrimitiveT> zzcqVar) throws GeneralSecurityException {
        if (zzcqVar != null) {
            Class<WrapperPrimitiveT> clsZzb = zzcqVar.zzb();
            if (this.zzb.containsKey(clsZzb)) {
                zzcq<?, ?> zzcqVar2 = this.zzb.get(clsZzb);
                if (zzcqVar2.equals(zzcqVar) && zzcqVar.equals(zzcqVar2)) {
                    return this;
                }
                throw new GeneralSecurityException("Attempt to register non-equal PrimitiveWrapper object or input class object for already existing object of type".concat(String.valueOf(clsZzb)));
            }
            this.zzb.put(clsZzb, zzcqVar);
            return this;
        }
        throw new NullPointerException("wrapper must be non-null");
    }

    public final zzol zza() {
        return new zzol(this);
    }
}
