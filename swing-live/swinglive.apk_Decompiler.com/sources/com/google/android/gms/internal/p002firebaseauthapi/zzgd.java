package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
final class zzgd {
    private static final zzxr zza;
    private static final zzoa<zzge, zzos> zzb;
    private static final zznw<zzos> zzc;
    private static final zzmx<zzgb, zzot> zzd;
    private static final zzmt<zzot> zze;

    static {
        zzxr zzxrVarZzb = zzpg.zzb("type.googleapis.com/google.crypto.tink.KmsAeadKey");
        zza = zzxrVarZzb;
        zzb = zzoa.zza(new zzoc() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgg
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoc
            public final zzow zza(zzci zzciVar) {
                return zzos.zzb((zzvd) ((zzaja) zzvd.zza().zza("type.googleapis.com/google.crypto.tink.KmsAeadKey").zza(((zzvm) ((zzaja) zzvm.zza().zza(((zzge) zzciVar).zzb()).zzf())).zzi()).zza(zzvt.RAW).zzf()));
            }
        }, zzge.class, zzos.class);
        zzc = zznw.zza(new zzny() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgf
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzny
            public final zzci zza(zzow zzowVar) {
                return zzgd.zzb((zzos) zzowVar);
            }
        }, zzxrVarZzb, zzos.class);
        zzd = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgi
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                return zzot.zza("type.googleapis.com/google.crypto.tink.KmsAeadKey", ((zzvl) ((zzaja) zzvl.zzb().zza((zzvm) ((zzaja) zzvm.zza().zza(((zzgb) zzbuVar).zzb().zzb()).zzf())).zzf())).zzi(), zzux.zzb.REMOTE, zzvt.RAW, null);
            }
        }, zzgb.class, zzot.class);
        zze = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgh
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzgd.zzb((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb, zzot.class);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzgb zzb(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.KmsAeadKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to LegacyKmsAeadProtoSerialization.parseKey");
        }
        if (zzotVar.zzc() != zzvt.RAW) {
            throw new GeneralSecurityException("KmsAeadKey are only accepted with RAW, got ".concat(String.valueOf(zzotVar.zzc())));
        }
        try {
            zzvl zzvlVarZza = zzvl.zza(zzotVar.zzd(), zzaip.zza());
            if (zzvlVarZza.zza() == 0) {
                return zzgb.zza(zzge.zza(zzvlVarZza.zzd().zzd()));
            }
            throw new GeneralSecurityException("KmsAeadKey are only accepted with version 0, got ".concat(String.valueOf(zzvlVarZza)));
        } catch (zzajj e) {
            throw new GeneralSecurityException("Parsing KmsAeadKey failed: ", e);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzge zzb(zzos zzosVar) throws GeneralSecurityException {
        if (zzosVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.KmsAeadKey")) {
            try {
                zzvm zzvmVarZza = zzvm.zza(zzosVar.zza().zze(), zzaip.zza());
                if (zzosVar.zza().zzd() == zzvt.RAW) {
                    return zzge.zza(zzvmVarZza.zzd());
                }
                throw new GeneralSecurityException("Only key templates with RAW are accepted, but got " + String.valueOf(zzosVar.zza().zzd()) + " with format " + String.valueOf(zzvmVarZza));
            } catch (zzajj e) {
                throw new GeneralSecurityException("Parsing KmsAeadKeyFormat failed: ", e);
            }
        }
        throw new IllegalArgumentException(a.m("Wrong type URL in call to LegacyKmsAeadProtoSerialization.parseParameters: ", zzosVar.zza().zzf()));
    }

    public static void zza() {
        zznv zznvVarZza = zznv.zza();
        zznvVarZza.zza(zzb);
        zznvVarZza.zza(zzc);
        zznvVarZza.zza(zzd);
        zznvVarZza.zza(zze);
    }
}
