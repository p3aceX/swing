package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzdm;
import com.google.android.gms.internal.p002firebaseauthapi.zzui;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
final class zzdq {
    private static final zzxr zza;
    private static final zzoa<zzdm, zzos> zzb;
    private static final zznw<zzos> zzc;
    private static final zzmx<zzdf, zzot> zzd;
    private static final zzmt<zzot> zze;

    static {
        zzxr zzxrVarZzb = zzpg.zzb("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey");
        zza = zzxrVarZzb;
        zzb = zzoa.zza(new zzoc() { // from class: com.google.android.gms.internal.firebase-auth-api.zzdp
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoc
            public final zzow zza(zzci zzciVar) {
                zzdm zzdmVar = (zzdm) zzciVar;
                return zzos.zzb((zzvd) ((zzaja) zzvd.zza().zza("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey").zza(((zzsg) ((zzaja) zzsg.zza().zza((zzsk) ((zzaja) zzsk.zzb().zza((zzsl) ((zzaja) zzsl.zzb().zza(zzdmVar.zzd()).zzf())).zza(zzdmVar.zzb()).zzf())).zza((zzuf) ((zzaja) zzuf.zzc().zza(zzdq.zzb(zzdmVar)).zza(zzdmVar.zzc()).zzf())).zzf())).zzi()).zza(zzdq.zza(zzdmVar.zzh())).zzf()));
            }
        }, zzdm.class, zzos.class);
        zzc = zznw.zza(new zzny() { // from class: com.google.android.gms.internal.firebase-auth-api.zzds
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzny
            public final zzci zza(zzow zzowVar) {
                return zzdq.zzb((zzos) zzowVar);
            }
        }, zzxrVarZzb, zzos.class);
        zzd = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzdr
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                zzdf zzdfVar = (zzdf) zzbuVar;
                return zzot.zza("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey", ((zzsd) ((zzaja) zzsd.zzb().zza((zzsh) ((zzaja) zzsh.zzb().zza((zzsl) ((zzaja) zzsl.zzb().zza(zzdfVar.zzc().zzd()).zzf())).zza(zzahm.zza(zzdfVar.zze().zza(zzct.zza(zzctVar)))).zzf())).zza((zzue) ((zzaja) zzue.zzb().zza(zzdq.zzb(zzdfVar.zzc())).zza(zzahm.zza(zzdfVar.zzf().zza(zzct.zza(zzctVar)))).zzf())).zzf())).zzi(), zzux.zzb.SYMMETRIC, zzdq.zza(zzdfVar.zzc().zzh()), zzdfVar.zza());
            }
        }, zzdf.class, zzot.class);
        zze = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzdu
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzdq.zzb((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb, zzot.class);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzdf zzb(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to AesCtrHmacAeadProtoSerialization.parseKey");
        }
        try {
            zzsd zzsdVarZza = zzsd.zza(zzotVar.zzd(), zzaip.zza());
            if (zzsdVarZza.zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            if (zzsdVarZza.zzd().zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys inner AES CTR keys are accepted");
            }
            if (zzsdVarZza.zze().zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys inner HMAC keys are accepted");
            }
            return zzdf.zzb().zza(zzdm.zzf().zza(zzsdVarZza.zzd().zzf().zzb()).zzb(zzsdVarZza.zze().zzf().zzb()).zzc(zzsdVarZza.zzd().zze().zza()).zzd(zzsdVarZza.zze().zze().zza()).zza(zza(zzsdVarZza.zze().zze().zzb())).zza(zza(zzotVar.zzc())).zza()).zza(zzxt.zza(zzsdVarZza.zzd().zzf().zzg(), zzct.zza(zzctVar))).zzb(zzxt.zza(zzsdVarZza.zze().zzf().zzg(), zzct.zza(zzctVar))).zza(zzotVar.zze()).zza();
        } catch (zzajj unused) {
            throw new GeneralSecurityException("Parsing AesCtrHmacAeadKey failed");
        }
    }

    private static zzdm.zzb zza(zzuc zzucVar) throws GeneralSecurityException {
        int i4 = zzdt.zzb[zzucVar.ordinal()];
        if (i4 == 1) {
            return zzdm.zzb.zza;
        }
        if (i4 == 2) {
            return zzdm.zzb.zzb;
        }
        if (i4 == 3) {
            return zzdm.zzb.zzc;
        }
        if (i4 == 4) {
            return zzdm.zzb.zzd;
        }
        if (i4 == 5) {
            return zzdm.zzb.zze;
        }
        throw new GeneralSecurityException(S.d(zzucVar.zza(), "Unable to parse HashType: "));
    }

    private static zzdm.zzc zza(zzvt zzvtVar) throws GeneralSecurityException {
        int i4 = zzdt.zza[zzvtVar.ordinal()];
        if (i4 == 1) {
            return zzdm.zzc.zza;
        }
        if (i4 == 2 || i4 == 3) {
            return zzdm.zzc.zzb;
        }
        if (i4 == 4) {
            return zzdm.zzc.zzc;
        }
        throw new GeneralSecurityException(S.d(zzvtVar.zza(), "Unable to parse OutputPrefixType: "));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzdm zzb(zzos zzosVar) throws GeneralSecurityException {
        if (zzosVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.AesCtrHmacAeadKey")) {
            try {
                zzsg zzsgVarZza = zzsg.zza(zzosVar.zza().zze(), zzaip.zza());
                if (zzsgVarZza.zzd().zzb() == 0) {
                    return zzdm.zzf().zza(zzsgVarZza.zzc().zza()).zzb(zzsgVarZza.zzd().zza()).zzc(zzsgVarZza.zzc().zze().zza()).zzd(zzsgVarZza.zzd().zzf().zza()).zza(zza(zzsgVarZza.zzd().zzf().zzb())).zza(zza(zzosVar.zza().zzd())).zza();
                }
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            } catch (zzajj e) {
                throw new GeneralSecurityException("Parsing AesCtrHmacAeadParameters failed: ", e);
            }
        }
        throw new IllegalArgumentException(a.m("Wrong type URL in call to AesCtrHmacAeadProtoSerialization.parseParameters: ", zzosVar.zza().zzf()));
    }

    private static zzui zzb(zzdm zzdmVar) throws GeneralSecurityException {
        zzuc zzucVar;
        zzui.zza zzaVarZza = zzui.zzc().zza(zzdmVar.zze());
        zzdm.zzb zzbVarZzg = zzdmVar.zzg();
        if (zzdm.zzb.zza.equals(zzbVarZzg)) {
            zzucVar = zzuc.SHA1;
        } else if (zzdm.zzb.zzb.equals(zzbVarZzg)) {
            zzucVar = zzuc.SHA224;
        } else if (zzdm.zzb.zzc.equals(zzbVarZzg)) {
            zzucVar = zzuc.SHA256;
        } else if (zzdm.zzb.zzd.equals(zzbVarZzg)) {
            zzucVar = zzuc.SHA384;
        } else if (zzdm.zzb.zze.equals(zzbVarZzg)) {
            zzucVar = zzuc.SHA512;
        } else {
            throw new GeneralSecurityException("Unable to serialize HashType ".concat(String.valueOf(zzbVarZzg)));
        }
        return (zzui) ((zzaja) zzaVarZza.zza(zzucVar).zzf());
    }

    private static zzvt zza(zzdm.zzc zzcVar) throws GeneralSecurityException {
        if (zzdm.zzc.zza.equals(zzcVar)) {
            return zzvt.TINK;
        }
        if (zzdm.zzc.zzb.equals(zzcVar)) {
            return zzvt.CRUNCHY;
        }
        if (zzdm.zzc.zzc.equals(zzcVar)) {
            return zzvt.RAW;
        }
        throw new GeneralSecurityException("Unable to serialize variant: ".concat(String.valueOf(zzcVar)));
    }

    public static void zza() {
        zznv zznvVarZza = zznv.zza();
        zznvVarZza.zza(zzb);
        zznvVarZza.zza(zzc);
        zznvVarZza.zza(zzd);
        zznvVarZza.zza(zze);
    }
}
