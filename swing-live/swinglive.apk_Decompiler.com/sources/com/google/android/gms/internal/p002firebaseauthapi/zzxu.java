package com.google.android.gms.internal.p002firebaseauthapi;

import java.math.BigInteger;

/* JADX INFO: loaded from: classes.dex */
public final class zzxu {
    private final BigInteger zza;

    private zzxu(BigInteger bigInteger) {
        this.zza = bigInteger;
    }

    public static zzxu zza(BigInteger bigInteger, zzct zzctVar) {
        if (zzctVar != null) {
            return new zzxu(bigInteger);
        }
        throw new NullPointerException("SecretKeyAccess required");
    }

    public final BigInteger zza(zzct zzctVar) {
        if (zzctVar != null) {
            return this.zza;
        }
        throw new NullPointerException("SecretKeyAccess required");
    }
}
