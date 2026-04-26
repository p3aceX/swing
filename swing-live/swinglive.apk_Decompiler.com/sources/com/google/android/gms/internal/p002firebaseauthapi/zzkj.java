package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzdm;
import com.google.android.gms.internal.p002firebaseauthapi.zzer;
import com.google.android.gms.internal.p002firebaseauthapi.zzjl;
import com.google.android.gms.internal.p002firebaseauthapi.zzjx;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzkj {
    private static final String zza = "type.googleapis.com/google.crypto.tink.EciesAeadHkdfPublicKey";
    private static final String zzb = "type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey";

    @Deprecated
    private static final zzvv zzc = zzvv.zzb();

    @Deprecated
    private static final zzvv zzd = zzvv.zzb();

    @Deprecated
    private static final zzvv zze = zzvv.zzb();

    static {
        try {
            zza();
        } catch (GeneralSecurityException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void zza() throws GeneralSecurityException {
        zzkm.zzc();
        zzko.zzc();
        zzcx.zza();
        zzis.zza();
        if (zzic.zzb()) {
            return;
        }
        zzcu.zza((zzoq) new zzje(), (zznb) new zzjj(), true);
        zzjq.zza();
        zznt zzntVarZza = zznt.zza();
        HashMap map = new HashMap();
        zzjl.zza zzaVarZzc = zzjl.zzc();
        zzjl.zzc zzcVar = zzjl.zzc.zza;
        zzjl.zza zzaVarZza = zzaVarZzc.zza(zzcVar);
        zzjl.zzb zzbVar = zzjl.zzb.zzc;
        zzjl.zza zzaVarZza2 = zzaVarZza.zza(zzbVar);
        zzjl.zze zzeVar = zzjl.zze.zzb;
        zzjl.zza zzaVarZza3 = zzaVarZza2.zza(zzeVar);
        zzjl.zzd zzdVar = zzjl.zzd.zza;
        zzjl.zza zzaVarZza4 = zzaVarZza3.zza(zzdVar);
        zzer.zza zzaVarZzc2 = zzer.zze().zza(12).zzb(16).zzc(16);
        zzer.zzb zzbVar2 = zzer.zzb.zzc;
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM", zzaVarZza4.zza(zzaVarZzc2.zza(zzbVar2).zza()).zza());
        zzjl.zza zzaVarZza5 = zzjl.zzc().zza(zzcVar).zza(zzbVar).zza(zzeVar);
        zzjl.zzd zzdVar2 = zzjl.zzd.zzc;
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM_RAW", zzaVarZza5.zza(zzdVar2).zza(zzer.zze().zza(12).zzb(16).zzc(16).zza(zzbVar2).zza()).zza());
        zzjl.zza zzaVarZza6 = zzjl.zzc().zza(zzcVar).zza(zzbVar);
        zzjl.zze zzeVar2 = zzjl.zze.zza;
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_GCM", zzaVarZza6.zza(zzeVar2).zza(zzdVar).zza(zzer.zze().zza(12).zzb(16).zzc(16).zza(zzbVar2).zza()).zza());
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_GCM_RAW", zzjl.zzc().zza(zzcVar).zza(zzbVar).zza(zzeVar2).zza(zzdVar2).zza(zzer.zze().zza(12).zzb(16).zzc(16).zza(zzbVar2).zza()).zza());
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM_COMPRESSED_WITHOUT_PREFIX", zzjl.zzc().zza(zzcVar).zza(zzbVar).zza(zzeVar2).zza(zzdVar2).zza(zzer.zze().zza(12).zzb(16).zzc(16).zza(zzbVar2).zza()).zza());
        zzjl.zza zzaVarZza7 = zzjl.zzc().zza(zzcVar).zza(zzbVar).zza(zzeVar).zza(zzdVar);
        zzdm.zza zzaVarZzc3 = zzdm.zzf().zza(16).zzb(32).zzd(16).zzc(16);
        zzdm.zzb zzbVar3 = zzdm.zzb.zzc;
        zzdm.zza zzaVarZza8 = zzaVarZzc3.zza(zzbVar3);
        zzdm.zzc zzcVar2 = zzdm.zzc.zzc;
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256", zzaVarZza7.zza(zzaVarZza8.zza(zzcVar2).zza()).zza());
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256_RAW", zzjl.zzc().zza(zzcVar).zza(zzbVar).zza(zzeVar).zza(zzdVar2).zza(zzdm.zzf().zza(16).zzb(32).zzd(16).zzc(16).zza(zzbVar3).zza(zzcVar2).zza()).zza());
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256", zzjl.zzc().zza(zzcVar).zza(zzbVar).zza(zzeVar2).zza(zzdVar).zza(zzdm.zzf().zza(16).zzb(32).zzd(16).zzc(16).zza(zzbVar3).zza(zzcVar2).zza()).zza());
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256_RAW", zzjl.zzc().zza(zzcVar).zza(zzbVar).zza(zzeVar2).zza(zzdVar2).zza(zzdm.zzf().zza(16).zzb(32).zzd(16).zzc(16).zza(zzbVar3).zza(zzcVar2).zza()).zza());
        zzntVarZza.zza(Collections.unmodifiableMap(map));
        zzcu.zza((zzoq) new zzlk(), (zznb) new zzlo(), true);
        zzkb.zza();
        zznt zzntVarZza2 = zznt.zza();
        HashMap map2 = new HashMap();
        zzjx.zzc zzcVarZzc = zzjx.zzc();
        zzjx.zzf zzfVar = zzjx.zzf.zza;
        zzjx.zzc zzcVarZza = zzcVarZzc.zza(zzfVar);
        zzjx.zzd zzdVar3 = zzjx.zzd.zzd;
        zzjx.zzc zzcVarZza2 = zzcVarZza.zza(zzdVar3);
        zzjx.zze zzeVar3 = zzjx.zze.zza;
        zzjx.zzc zzcVarZza3 = zzcVarZza2.zza(zzeVar3);
        zzjx.zza zzaVar = zzjx.zza.zza;
        map2.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_128_GCM", zzcVarZza3.zza(zzaVar).zza());
        zzjx.zzc zzcVarZzc2 = zzjx.zzc();
        zzjx.zzf zzfVar2 = zzjx.zzf.zzc;
        map2.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_128_GCM_RAW", zzcVarZzc2.zza(zzfVar2).zza(zzdVar3).zza(zzeVar3).zza(zzaVar).zza());
        zzjx.zzc zzcVarZza4 = zzjx.zzc().zza(zzfVar).zza(zzdVar3).zza(zzeVar3);
        zzjx.zza zzaVar2 = zzjx.zza.zzb;
        map2.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_256_GCM", zzcVarZza4.zza(zzaVar2).zza());
        map2.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_256_GCM_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar3).zza(zzeVar3).zza(zzaVar2).zza());
        zzjx.zzc zzcVarZza5 = zzjx.zzc().zza(zzfVar).zza(zzdVar3).zza(zzeVar3);
        zzjx.zza zzaVar3 = zzjx.zza.zzc;
        map2.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_CHACHA20_POLY1305", zzcVarZza5.zza(zzaVar3).zza());
        map2.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_CHACHA20_POLY1305_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar3).zza(zzeVar3).zza(zzaVar3).zza());
        zzjx.zzc zzcVarZza6 = zzjx.zzc().zza(zzfVar);
        zzjx.zzd zzdVar4 = zzjx.zzd.zza;
        map2.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_128_GCM", zzcVarZza6.zza(zzdVar4).zza(zzeVar3).zza(zzaVar).zza());
        map2.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_128_GCM_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar4).zza(zzeVar3).zza(zzaVar).zza());
        map2.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_256_GCM", zzjx.zzc().zza(zzfVar).zza(zzdVar4).zza(zzeVar3).zza(zzaVar2).zza());
        map2.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_256_GCM_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar4).zza(zzeVar3).zza(zzaVar2).zza());
        zzjx.zzc zzcVarZza7 = zzjx.zzc().zza(zzfVar);
        zzjx.zzd zzdVar5 = zzjx.zzd.zzb;
        zzjx.zzc zzcVarZza8 = zzcVarZza7.zza(zzdVar5);
        zzjx.zze zzeVar4 = zzjx.zze.zzb;
        map2.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_128_GCM", zzcVarZza8.zza(zzeVar4).zza(zzaVar).zza());
        map2.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_128_GCM_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar5).zza(zzeVar4).zza(zzaVar).zza());
        map2.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_256_GCM", zzjx.zzc().zza(zzfVar).zza(zzdVar5).zza(zzeVar4).zza(zzaVar2).zza());
        map2.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_256_GCM_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar5).zza(zzeVar4).zza(zzaVar2).zza());
        zzjx.zzc zzcVarZza9 = zzjx.zzc().zza(zzfVar);
        zzjx.zzd zzdVar6 = zzjx.zzd.zzc;
        zzjx.zzc zzcVarZza10 = zzcVarZza9.zza(zzdVar6);
        zzjx.zze zzeVar5 = zzjx.zze.zzc;
        map2.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_128_GCM", zzcVarZza10.zza(zzeVar5).zza(zzaVar).zza());
        map2.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_128_GCM_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar6).zza(zzeVar5).zza(zzaVar).zza());
        map2.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_256_GCM", zzjx.zzc().zza(zzfVar).zza(zzdVar6).zza(zzeVar5).zza(zzaVar2).zza());
        map2.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_256_GCM_RAW", zzjx.zzc().zza(zzfVar2).zza(zzdVar6).zza(zzeVar5).zza(zzaVar2).zza());
        zzntVarZza2.zza(Collections.unmodifiableMap(map2));
    }
}
