package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zznk {
    private static final zznk zza = new zznk();
    private final Map<Class<? extends zzci>, zznn<? extends zzci>> zzb = new HashMap();

    private final synchronized <ParametersT extends zzci> zzbu zzb(ParametersT parameterst, Integer num) {
        zznn<? extends zzci> zznnVar;
        zznnVar = this.zzb.get(parameterst.getClass());
        if (zznnVar == null) {
            throw new GeneralSecurityException("Cannot create a new key for parameters " + String.valueOf(parameterst) + ": no key creator for this class was registered.");
        }
        return zznnVar.zza(parameterst, null);
    }

    public final zzbu zza(zzci zzciVar, Integer num) {
        return zzb(zzciVar, null);
    }

    public static zznk zza() {
        return zza;
    }

    public final synchronized <ParametersT extends zzci> void zza(zznn<ParametersT> zznnVar, Class<ParametersT> cls) {
        try {
            zznn<? extends zzci> zznnVar2 = this.zzb.get(cls);
            if (zznnVar2 != null && !zznnVar2.equals(zznnVar)) {
                throw new GeneralSecurityException("Different key creator for parameters class " + String.valueOf(cls) + " already inserted");
            }
            this.zzb.put(cls, zznnVar);
        } catch (Throwable th) {
            throw th;
        }
    }
}
