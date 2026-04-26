package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzgj;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzgo {
    private static final zzxr zza;
    private static final zzoa<zzgj, zzos> zzb;
    private static final zznw<zzos> zzc;
    private static final zzmx<zzgk, zzot> zzd;
    private static final zzmt<zzot> zze;

    static {
        zzxr zzxrVarZzb = zzpg.zzb("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey");
        zza = zzxrVarZzb;
        zzb = zzoa.zza(new zzoc() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgn
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoc
            public final zzow zza(zzci zzciVar) {
                return zzos.zzb((zzvd) ((zzaja) zzvd.zza().zza("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey").zza(zzgo.zzb((zzgj) zzciVar).zzi()).zza(zzvt.RAW).zzf()));
            }
        }, zzgj.class, zzos.class);
        zzc = zznw.zza(new zzny() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgq
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzny
            public final zzci zza(zzow zzowVar) {
                return zzgo.zzb((zzos) zzowVar);
            }
        }, zzxrVarZzb, zzos.class);
        zzd = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgp
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                return zzot.zza("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey", ((zzvp) ((zzaja) zzvp.zzb().zza(zzgo.zzb(((zzgk) zzbuVar).zzb())).zzf())).zzi(), zzux.zzb.REMOTE, zzvt.RAW, null);
            }
        }, zzgk.class, zzot.class);
        zze = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgs
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzgo.zzb((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb, zzot.class);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzgk zzb(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to LegacyKmsEnvelopeAeadProtoSerialization.parseKey");
        }
        try {
            zzvp zzvpVarZza = zzvp.zza(zzotVar.zzd(), zzaip.zza());
            if (zzotVar.zzc() != zzvt.RAW) {
                throw new GeneralSecurityException("KmsEnvelopeAeadKeys are only accepted with OutputPrefixType RAW, got ".concat(String.valueOf(zzvpVarZza)));
            }
            if (zzvpVarZza.zza() == 0) {
                return zzgk.zza(zza(zzvpVarZza.zzd()));
            }
            throw new GeneralSecurityException("KmsEnvelopeAeadKeys are only accepted with version 0, got ".concat(String.valueOf(zzvpVarZza)));
        } catch (zzajj e) {
            throw new GeneralSecurityException("Parsing KmsEnvelopeAeadKey failed: ", e);
        }
    }

    private static zzgj zza(zzvq zzvqVar) throws GeneralSecurityException {
        zzgj.zzb zzbVar;
        zzci zzciVarZza = zzcv.zza(((zzvd) ((zzaja) zzvd.zza().zza(zzvqVar.zza().zzf()).zza(zzvqVar.zza().zze()).zza(zzvt.RAW).zzf())).zzj());
        if (zzciVarZza instanceof zzer) {
            zzbVar = zzgj.zzb.zza;
        } else if (zzciVarZza instanceof zzfo) {
            zzbVar = zzgj.zzb.zzc;
        } else if (zzciVarZza instanceof zzhd) {
            zzbVar = zzgj.zzb.zzb;
        } else if (zzciVarZza instanceof zzdm) {
            zzbVar = zzgj.zzb.zzd;
        } else if (zzciVarZza instanceof zzea) {
            zzbVar = zzgj.zzb.zze;
        } else if (zzciVarZza instanceof zzfa) {
            zzbVar = zzgj.zzb.zzf;
        } else {
            throw new GeneralSecurityException("Unsupported DEK parameters when parsing ".concat(String.valueOf(zzciVarZza)));
        }
        return new zzgj.zza().zza(zzvqVar.zze()).zza((zzdc) zzciVarZza).zza(zzbVar).zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzgj zzb(zzos zzosVar) throws GeneralSecurityException {
        if (zzosVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey")) {
            try {
                return zza(zzvq.zza(zzosVar.zza().zze(), zzaip.zza()));
            } catch (zzajj e) {
                throw new GeneralSecurityException("Parsing KmsEnvelopeAeadKeyFormat failed: ", e);
            }
        }
        throw new IllegalArgumentException(a.m("Wrong type URL in call to LegacyKmsEnvelopeAeadProtoSerialization.parseParameters: ", zzosVar.zza().zzf()));
    }

    private static zzvq zzb(zzgj zzgjVar) throws GeneralSecurityException {
        try {
            return (zzvq) ((zzaja) zzvq.zzb().zza(zzgjVar.zzc()).zza(zzvd.zza(zzcv.zza(zzgjVar.zzb()), zzaip.zza())).zzf());
        } catch (zzajj e) {
            throw new GeneralSecurityException("Parsing KmsEnvelopeAeadKeyFormat failed: ", e);
        }
    }

    public static void zza() {
        zznv zznvVarZza = zznv.zza();
        zznvVarZza.zza(zzb);
        zznvVarZza.zza(zzc);
        zznvVarZza.zza(zzd);
        zznvVarZza.zza(zze);
    }
}
