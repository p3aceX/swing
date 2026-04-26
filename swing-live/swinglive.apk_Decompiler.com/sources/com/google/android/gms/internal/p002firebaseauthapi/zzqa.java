package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class zzqa implements zzcq<zzpx, zzpx> {
    private static final zzqa zza = new zzqa();

    private zzqa() {
    }

    public static void zzc() {
        zzcu.zza(zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcq
    public final Class<zzpx> zza() {
        return zzpx.class;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcq
    public final Class<zzpx> zzb() {
        return zzpx.class;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcq
    public final /* synthetic */ zzpx zza(zzch<zzpx> zzchVar) throws GeneralSecurityException {
        if (zzchVar == null) {
            throw new GeneralSecurityException("primitive set must be non-null");
        }
        if (zzchVar.zza() == null) {
            throw new GeneralSecurityException("no primary in primitive set");
        }
        Iterator<List<zzcm<zzpx>>> it = zzchVar.zzd().iterator();
        while (it.hasNext()) {
            Iterator<zzcm<zzpx>> it2 = it.next().iterator();
            while (it2.hasNext()) {
                it2.next().zze();
            }
        }
        return new zzpz(zzchVar);
    }
}
