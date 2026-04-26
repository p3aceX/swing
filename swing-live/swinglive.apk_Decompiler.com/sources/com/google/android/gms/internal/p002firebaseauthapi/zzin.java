package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zziq;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.InvalidAlgorithmParameterException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzin {
    private static final zzoe<zzij, zzbq> zza = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzim
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzin.zza((zzij) zzbuVar);
        }
    }, zzij.class, zzbq.class);
    private static final zzbt<zzbq> zzb = zznd.zza("type.googleapis.com/google.crypto.tink.AesSivKey", zzbq.class, zzux.zzb.SYMMETRIC, zztb.zze());
    private static final zznp<zziq> zzc = new zznp() { // from class: com.google.android.gms.internal.firebase-auth-api.zzip
    };
    private static final zznn<zziq> zzd = new zznn() { // from class: com.google.android.gms.internal.firebase-auth-api.zzio
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zznn
        public final zzbu zza(zzci zzciVar, Integer num) {
            return zzin.zza((zziq) zzciVar, null);
        }
    };

    public static /* synthetic */ zzbq zza(zzij zzijVar) throws InvalidAlgorithmParameterException {
        zza(zzijVar.zzc());
        return zzwf.zza(zzijVar);
    }

    public static zzij zza(zziq zziqVar, Integer num) throws InvalidAlgorithmParameterException {
        zza(zziqVar);
        return zzij.zzb().zza(zziqVar).zza(num).zza(zzxt.zza(zziqVar.zzb())).zza();
    }

    public static void zza(boolean z4) {
        zzjb.zza();
        zzns.zza().zza(zza);
        zznt zzntVarZza = zznt.zza();
        HashMap map = new HashMap();
        map.put("AES256_SIV", zziz.zza);
        map.put("AES256_SIV_RAW", zziq.zzc().zza(64).zza(zziq.zzb.zzc).zza());
        zzntVarZza.zza(Collections.unmodifiableMap(map));
        zznm.zza().zza(zzc, zziq.class);
        zznk.zza().zza(zzd, zziq.class);
        zzcu.zza((zzbt) zzb, true);
    }

    private static void zza(zziq zziqVar) throws InvalidAlgorithmParameterException {
        if (zziqVar.zzb() != 64) {
            throw new InvalidAlgorithmParameterException(a.l("invalid key size: ", zziqVar.zzb(), ". Valid keys must have 64 bytes."));
        }
    }
}
