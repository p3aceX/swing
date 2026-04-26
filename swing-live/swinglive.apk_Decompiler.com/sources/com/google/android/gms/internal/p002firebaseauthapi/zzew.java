package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzfa;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.NoSuchAlgorithmException;
import java.util.Collections;
import java.util.HashMap;
import javax.crypto.Cipher;
import javax.crypto.NoSuchPaddingException;

/* JADX INFO: loaded from: classes.dex */
public final class zzew {
    private static final zzoe<zzet, zzbh> zza = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzez
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzia.zza((zzet) zzbuVar);
        }
    }, zzet.class, zzbh.class);
    private static final zznn<zzfa> zzb = new zznn() { // from class: com.google.android.gms.internal.firebase-auth-api.zzey
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zznn
        public final zzbu zza(zzci zzciVar, Integer num) {
            zzfa zzfaVar = (zzfa) zzciVar;
            return zzet.zzb().zza(zzfaVar).zza((Integer) null).zza(zzxt.zza(zzfaVar.zzb())).zza();
        }
    };
    private static final zznp<zzfa> zzc = new zznp() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfb
    };
    private static final zzbt<zzbh> zzd = zznd.zza("type.googleapis.com/google.crypto.tink.AesGcmSivKey", zzbh.class, zzux.zzb.SYMMETRIC, zzsx.zze());

    public static void zza(boolean z4) {
        zzff.zza();
        if (zza()) {
            zzns.zza().zza(zza);
            zznt zzntVarZza = zznt.zza();
            HashMap map = new HashMap();
            zzfa.zza zzaVarZza = zzfa.zzc().zza(16);
            zzfa.zzb zzbVar = zzfa.zzb.zza;
            map.put("AES128_GCM_SIV", zzaVarZza.zza(zzbVar).zza());
            zzfa.zza zzaVarZza2 = zzfa.zzc().zza(16);
            zzfa.zzb zzbVar2 = zzfa.zzb.zzc;
            map.put("AES128_GCM_SIV_RAW", zzaVarZza2.zza(zzbVar2).zza());
            map.put("AES256_GCM_SIV", zzfa.zzc().zza(32).zza(zzbVar).zza());
            map.put("AES256_GCM_SIV_RAW", zzfa.zzc().zza(32).zza(zzbVar2).zza());
            zzntVarZza.zza(Collections.unmodifiableMap(map));
            zznm.zza().zza(zzc, zzfa.class);
            zznk.zza().zza(zzb, zzfa.class);
            zzcu.zza((zzbt) zzd, true);
        }
    }

    private static boolean zza() {
        try {
            Cipher.getInstance("AES/GCM-SIV/NoPadding");
            return true;
        } catch (NoSuchAlgorithmException | NoSuchPaddingException unused) {
            return false;
        }
    }
}
