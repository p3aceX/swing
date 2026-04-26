package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzfa;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
final class zzff {
    private static final zzxr zza;
    private static final zzoa<zzfa, zzos> zzb;
    private static final zznw<zzos> zzc;
    private static final zzmx<zzet, zzot> zzd;
    private static final zzmt<zzot> zze;

    static {
        zzxr zzxrVarZzb = zzpg.zzb("type.googleapis.com/google.crypto.tink.AesGcmSivKey");
        zza = zzxrVarZzb;
        zzb = zzoa.zza(new zzoc() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfe
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoc
            public final zzow zza(zzci zzciVar) {
                zzfa zzfaVar = (zzfa) zzciVar;
                return zzos.zzb((zzvd) ((zzaja) zzvd.zza().zza("type.googleapis.com/google.crypto.tink.AesGcmSivKey").zza(((zzta) ((zzaja) zzta.zzc().zza(zzfaVar.zzb()).zzf())).zzi()).zza(zzff.zza(zzfaVar.zzd())).zzf()));
            }
        }, zzfa.class, zzos.class);
        zzc = zznw.zza(new zzny() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfh
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzny
            public final zzci zza(zzow zzowVar) {
                return zzff.zzb((zzos) zzowVar);
            }
        }, zzxrVarZzb, zzos.class);
        zzd = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfg
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                zzet zzetVar = (zzet) zzbuVar;
                return zzot.zza("type.googleapis.com/google.crypto.tink.AesGcmSivKey", ((zzsx) ((zzaja) zzsx.zzb().zza(zzahm.zza(zzetVar.zze().zza(zzct.zza(zzctVar)))).zzf())).zzi(), zzux.zzb.SYMMETRIC, zzff.zza(zzetVar.zzc().zzd()), zzetVar.zza());
            }
        }, zzet.class, zzot.class);
        zze = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfj
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzff.zzb((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb, zzot.class);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzet zzb(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.AesGcmSivKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to AesGcmSivProtoSerialization.parseKey");
        }
        try {
            zzsx zzsxVarZza = zzsx.zza(zzotVar.zzd(), zzaip.zza());
            if (zzsxVarZza.zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            return zzet.zzb().zza(zzfa.zzc().zza(zzsxVarZza.zzd().zzb()).zza(zza(zzotVar.zzc())).zza()).zza(zzxt.zza(zzsxVarZza.zzd().zzg(), zzct.zza(zzctVar))).zza(zzotVar.zze()).zza();
        } catch (zzajj unused) {
            throw new GeneralSecurityException("Parsing AesGcmSivKey failed");
        }
    }

    private static zzfa.zzb zza(zzvt zzvtVar) throws GeneralSecurityException {
        int i4 = zzfi.zza[zzvtVar.ordinal()];
        if (i4 == 1) {
            return zzfa.zzb.zza;
        }
        if (i4 == 2 || i4 == 3) {
            return zzfa.zzb.zzb;
        }
        if (i4 == 4) {
            return zzfa.zzb.zzc;
        }
        throw new GeneralSecurityException(S.d(zzvtVar.zza(), "Unable to parse OutputPrefixType: "));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzfa zzb(zzos zzosVar) throws GeneralSecurityException {
        if (zzosVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.AesGcmSivKey")) {
            try {
                zzta zztaVarZza = zzta.zza(zzosVar.zza().zze(), zzaip.zza());
                if (zztaVarZza.zzb() == 0) {
                    return zzfa.zzc().zza(zztaVarZza.zza()).zza(zza(zzosVar.zza().zzd())).zza();
                }
                throw new GeneralSecurityException("Only version 0 parameters are accepted");
            } catch (zzajj e) {
                throw new GeneralSecurityException("Parsing AesGcmSivParameters failed: ", e);
            }
        }
        throw new IllegalArgumentException(a.m("Wrong type URL in call to AesGcmSivProtoSerialization.parseParameters: ", zzosVar.zza().zzf()));
    }

    private static zzvt zza(zzfa.zzb zzbVar) throws GeneralSecurityException {
        if (zzfa.zzb.zza.equals(zzbVar)) {
            return zzvt.TINK;
        }
        if (zzfa.zzb.zzb.equals(zzbVar)) {
            return zzvt.CRUNCHY;
        }
        if (zzfa.zzb.zzc.equals(zzbVar)) {
            return zzvt.RAW;
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
