package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzpp;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzpm {
    private static final zznn<zzpp> zza = new zznn() { // from class: com.google.android.gms.internal.firebase-auth-api.zzpl
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zznn
        public final zzbu zza(zzci zzciVar, Integer num) {
            return zzpm.zza((zzpp) zzciVar, null);
        }
    };
    private static final zzoe<zzpi, zzpx> zzb = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzpo
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzpm.zzb((zzpi) zzbuVar);
        }
    }, zzpi.class, zzpx.class);
    private static final zzoe<zzpi, zzcf> zzc = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzpn
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzpm.zza((zzpi) zzbuVar);
        }
    }, zzpi.class, zzcf.class);
    private static final zzbt<zzcf> zzd = zznd.zza("type.googleapis.com/google.crypto.tink.AesCmacKey", zzcf.class, zzux.zzb.SYMMETRIC, zzry.zzf());

    public static /* synthetic */ zzcf zza(zzpi zzpiVar) throws GeneralSecurityException {
        zza((zzpp) zzpiVar.zzc());
        return zzxo.zza(zzpiVar);
    }

    public static /* synthetic */ zzpx zzb(zzpi zzpiVar) throws GeneralSecurityException {
        zza((zzpp) zzpiVar.zzc());
        return new zzre(zzpiVar);
    }

    public static /* synthetic */ zzpi zza(zzpp zzppVar, Integer num) throws GeneralSecurityException {
        zza(zzppVar);
        return zzpi.zzb().zza(zzppVar).zza(zzxt.zza(zzppVar.zzc())).zza(num).zza();
    }

    public static void zza(boolean z4) {
        zzpr.zza();
        zznk.zza().zza(zza, zzpp.class);
        zzns.zza().zza(zzb);
        zzns.zza().zza(zzc);
        zznt zzntVarZza = zznt.zza();
        HashMap map = new HashMap();
        zzpp zzppVar = zzqv.zzc;
        map.put("AES_CMAC", zzppVar);
        map.put("AES256_CMAC", zzppVar);
        map.put("AES256_CMAC_RAW", zzpp.zzd().zza(32).zzb(16).zza(zzpp.zzb.zzd).zza());
        zzntVarZza.zza(Collections.unmodifiableMap(map));
        zzcu.zza((zzbt) zzd, true);
    }

    private static void zza(zzpp zzppVar) throws GeneralSecurityException {
        if (zzppVar.zzc() != 32) {
            throw new GeneralSecurityException("AesCmacKey size wrong, must be 32 bytes");
        }
    }
}
