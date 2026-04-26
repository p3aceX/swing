package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzrd implements zzpx {
    private static final zzic.zza zza = zzic.zza.zzb;
    private final zzqb zzb;

    public zzrd(zzqb zzqbVar) throws GeneralSecurityException {
        if (!zza.zza()) {
            throw new GeneralSecurityException("Can not use HMAC in FIPS-mode, as BoringCrypto module is not available.");
        }
        this.zzb = zzqbVar;
    }
}
