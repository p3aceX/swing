package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzea;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public final class zzdz {
    private static final zzoe<zzdv, zzbh> zza = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzdy
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzwb.zza((zzdv) zzbuVar);
        }
    }, zzdv.class, zzbh.class);
    private static final zzbt<zzbh> zzb = zznd.zza("type.googleapis.com/google.crypto.tink.AesEaxKey", zzbh.class, zzux.zzb.SYMMETRIC, zzso.zzf());
    private static final zznn<zzea> zzc = new zznn() { // from class: com.google.android.gms.internal.firebase-auth-api.zzeb
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zznn
        public final zzbu zza(zzci zzciVar, Integer num) {
            return zzdz.zza((zzea) zzciVar, null);
        }
    };

    public static /* synthetic */ zzdv zza(zzea zzeaVar, Integer num) throws GeneralSecurityException {
        if (zzeaVar.zzc() != 24) {
            return zzdv.zzb().zza(zzeaVar).zza(num).zza(zzxt.zza(zzeaVar.zzc())).zza();
        }
        throw new GeneralSecurityException("192 bit AES GCM Parameters are not valid");
    }

    public static String zza() {
        return "type.googleapis.com/google.crypto.tink.AesEaxKey";
    }

    public static void zza(boolean z4) {
        zzef.zza();
        zzns.zza().zza(zza);
        zznt zzntVarZza = zznt.zza();
        HashMap map = new HashMap();
        map.put("AES128_EAX", zzgr.zzc);
        zzea.zza zzaVarZzc = zzea.zze().zza(16).zzb(16).zzc(16);
        zzea.zzb zzbVar = zzea.zzb.zzc;
        map.put("AES128_EAX_RAW", zzaVarZzc.zza(zzbVar).zza());
        map.put("AES256_EAX", zzgr.zzd);
        map.put("AES256_EAX_RAW", zzea.zze().zza(16).zzb(32).zzc(16).zza(zzbVar).zza());
        zzntVarZza.zza(Collections.unmodifiableMap(map));
        zznk.zza().zza(zzc, zzea.class);
        zzcu.zza((zzbt) zzb, true);
    }
}
