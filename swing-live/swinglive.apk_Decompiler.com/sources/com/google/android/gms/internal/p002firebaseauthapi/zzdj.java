package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzdm;
import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzdj {
    private static final zzoe<zzdf, zzbh> zza = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzdi
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzws.zza((zzdf) zzbuVar);
        }
    }, zzdf.class, zzbh.class);
    private static final zzbt<zzbh> zzb = zznd.zza("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey", zzbh.class, zzux.zzb.SYMMETRIC, zzsd.zzf());
    private static final zznp<zzdm> zzc = new zznp() { // from class: com.google.android.gms.internal.firebase-auth-api.zzdl
    };
    private static final zznn<zzdm> zzd = new zznn() { // from class: com.google.android.gms.internal.firebase-auth-api.zzdk
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zznn
        public final zzbu zza(zzci zzciVar, Integer num) {
            return zzdj.zza((zzdm) zzciVar, null);
        }
    };

    public static zzdf zza(zzdm zzdmVar, Integer num) throws GeneralSecurityException {
        if (zzdmVar.zzb() == 16 || zzdmVar.zzb() == 32) {
            return zzdf.zzb().zza(zzdmVar).zza(num).zza(zzxt.zza(zzdmVar.zzb())).zzb(zzxt.zza(zzdmVar.zzc())).zza();
        }
        throw new GeneralSecurityException("AES key size must be 16 or 32 bytes");
    }

    public static String zza() {
        return "type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey";
    }

    public static void zza(boolean z4) {
        zzdq.zza();
        zzns.zza().zza(zza);
        zznt zzntVarZza = zznt.zza();
        HashMap map = new HashMap();
        map.put("AES128_CTR_HMAC_SHA256", zzgr.zze);
        zzdm.zza zzaVarZzc = zzdm.zzf().zza(16).zzb(32).zzd(16).zzc(16);
        zzdm.zzb zzbVar = zzdm.zzb.zzc;
        zzdm.zza zzaVarZza = zzaVarZzc.zza(zzbVar);
        zzdm.zzc zzcVar = zzdm.zzc.zzc;
        map.put("AES128_CTR_HMAC_SHA256_RAW", zzaVarZza.zza(zzcVar).zza());
        map.put("AES256_CTR_HMAC_SHA256", zzgr.zzf);
        map.put("AES256_CTR_HMAC_SHA256_RAW", zzdm.zzf().zza(32).zzb(32).zzd(32).zzc(16).zza(zzbVar).zza(zzcVar).zza());
        zzntVarZza.zza(Collections.unmodifiableMap(map));
        zznm.zza().zza(zzc, zzdm.class);
        zznk.zza().zza(zzd, zzdm.class);
        zzmn.zza().zza((zzbt) zzb, zzic.zza.zzb, true);
    }
}
