package com.google.android.gms.internal.p002firebaseauthapi;

import java.lang.Enum;
import java.security.GeneralSecurityException;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zzmf<E extends Enum<E>, O> {
    private final Map<E, O> zza;
    private final Map<O, E> zzb;

    public static <E extends Enum<E>, O> zzmi<E, O> zza() {
        return new zzmi<>();
    }

    private zzmf(Map<E, O> map, Map<O, E> map2) {
        this.zza = map;
        this.zzb = map2;
    }

    public final E zza(O o4) throws GeneralSecurityException {
        E e = this.zzb.get(o4);
        if (e != null) {
            return e;
        }
        throw new GeneralSecurityException("Unable to convert object enum: ".concat(String.valueOf(o4)));
    }

    public final O zza(E e) throws GeneralSecurityException {
        O o4 = this.zza.get(e);
        if (o4 != null) {
            return o4;
        }
        throw new GeneralSecurityException("Unable to convert proto enum: ".concat(String.valueOf(e)));
    }
}
