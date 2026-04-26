package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import java.security.GeneralSecurityException;
import java.util.concurrent.CopyOnWriteArrayList;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
public final class zzcg {
    private static final CopyOnWriteArrayList<zzcd> zza = new CopyOnWriteArrayList<>();

    @Deprecated
    public static zzcd zza(String str) throws GeneralSecurityException {
        for (zzcd zzcdVar : zza) {
            if (zzcdVar.zzb(str)) {
                return zzcdVar;
            }
        }
        throw new GeneralSecurityException(a.m("No KMS client does support: ", str));
    }
}
