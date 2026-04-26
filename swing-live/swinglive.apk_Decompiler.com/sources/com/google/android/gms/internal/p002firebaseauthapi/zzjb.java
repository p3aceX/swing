package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zziq;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class zzjb {
    private static final zzxr zza;
    private static final zzoa<zziq, zzos> zzb;
    private static final zznw<zzos> zzc;
    private static final zzmx<zzij, zzot> zzd;
    private static final zzmt<zzot> zze;
    private static final Map<zziq.zzb, zzvt> zzf;
    private static final Map<zzvt, zziq.zzb> zzg;

    static {
        zzxr zzxrVarZzb = zzpg.zzb("type.googleapis.com/google.crypto.tink.AesSivKey");
        zza = zzxrVarZzb;
        zzb = zzoa.zza(new zzoc() { // from class: com.google.android.gms.internal.firebase-auth-api.zzja
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoc
            public final zzow zza(zzci zzciVar) {
                zziq zziqVar = (zziq) zzciVar;
                return zzos.zzb((zzvd) ((zzaja) zzvd.zza().zza("type.googleapis.com/google.crypto.tink.AesSivKey").zza(((zzte) ((zzaja) zzte.zzc().zza(zziqVar.zzb()).zzf())).zzi()).zza(zzjb.zza(zziqVar.zzd())).zzf()));
            }
        }, zziq.class, zzos.class);
        zzc = zznw.zza(new zzny() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjd
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzny
            public final zzci zza(zzow zzowVar) {
                return zzjb.zzb((zzos) zzowVar);
            }
        }, zzxrVarZzb, zzos.class);
        zzd = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjc
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                zzij zzijVar = (zzij) zzbuVar;
                return zzot.zza("type.googleapis.com/google.crypto.tink.AesSivKey", ((zztb) ((zzaja) zztb.zzb().zza(zzahm.zza(zzijVar.zze().zza(zzct.zza(zzctVar)))).zzf())).zzi(), zzux.zzb.SYMMETRIC, zzjb.zza(zzijVar.zzc().zzd()), zzijVar.zza());
            }
        }, zzij.class, zzot.class);
        zze = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjf
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzjb.zzb((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb, zzot.class);
        HashMap map = new HashMap();
        zziq.zzb zzbVar = zziq.zzb.zzc;
        zzvt zzvtVar = zzvt.RAW;
        map.put(zzbVar, zzvtVar);
        zziq.zzb zzbVar2 = zziq.zzb.zza;
        zzvt zzvtVar2 = zzvt.TINK;
        map.put(zzbVar2, zzvtVar2);
        zziq.zzb zzbVar3 = zziq.zzb.zzb;
        zzvt zzvtVar3 = zzvt.CRUNCHY;
        map.put(zzbVar3, zzvtVar3);
        zzf = Collections.unmodifiableMap(map);
        EnumMap enumMap = new EnumMap(zzvt.class);
        enumMap.put(zzvtVar, zzbVar);
        enumMap.put(zzvtVar2, zzbVar2);
        enumMap.put(zzvtVar3, zzbVar3);
        enumMap.put(zzvt.LEGACY, zzbVar3);
        zzg = Collections.unmodifiableMap(enumMap);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzij zzb(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.AesSivKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to AesSivParameters.parseParameters");
        }
        try {
            zztb zztbVarZza = zztb.zza(zzotVar.zzd(), zzaip.zza());
            if (zztbVarZza.zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            return zzij.zzb().zza(zziq.zzc().zza(zztbVarZza.zzd().zzb()).zza(zza(zzotVar.zzc())).zza()).zza(zzxt.zza(zztbVarZza.zzd().zzg(), zzct.zza(zzctVar))).zza(zzotVar.zze()).zza();
        } catch (zzajj unused) {
            throw new GeneralSecurityException("Parsing AesSivKey failed");
        }
    }

    private static zziq.zzb zza(zzvt zzvtVar) throws GeneralSecurityException {
        Map<zzvt, zziq.zzb> map = zzg;
        if (map.containsKey(zzvtVar)) {
            return map.get(zzvtVar);
        }
        throw new GeneralSecurityException(S.d(zzvtVar.zza(), "Unable to parse OutputPrefixType: "));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zziq zzb(zzos zzosVar) throws GeneralSecurityException {
        if (zzosVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.AesSivKey")) {
            try {
                zzte zzteVarZza = zzte.zza(zzosVar.zza().zze(), zzaip.zza());
                if (zzteVarZza.zzb() == 0) {
                    return zziq.zzc().zza(zzteVarZza.zza()).zza(zza(zzosVar.zza().zzd())).zza();
                }
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            } catch (zzajj e) {
                throw new GeneralSecurityException("Parsing AesSivParameters failed: ", e);
            }
        }
        throw new IllegalArgumentException(a.m("Wrong type URL in call to AesSivParameters.parseParameters: ", zzosVar.zza().zzf()));
    }

    private static zzvt zza(zziq.zzb zzbVar) throws GeneralSecurityException {
        Map<zziq.zzb, zzvt> map = zzf;
        if (map.containsKey(zzbVar)) {
            return map.get(zzbVar);
        }
        throw new GeneralSecurityException("Unable to serialize variant: ".concat(String.valueOf(zzbVar)));
    }

    public static void zza() {
        zznv zznvVarZza = zznv.zza();
        zznvVarZza.zza(zzb);
        zznvVarZza.zza(zzc);
        zznvVarZza.zza(zzd);
        zznvVarZza.zza(zze);
    }
}
