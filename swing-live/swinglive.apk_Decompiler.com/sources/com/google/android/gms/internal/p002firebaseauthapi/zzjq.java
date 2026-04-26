package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzjl;
import com.google.android.gms.internal.p002firebaseauthapi.zzts;
import com.google.android.gms.internal.p002firebaseauthapi.zztw;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;
import java.security.spec.ECPoint;

/* JADX INFO: loaded from: classes.dex */
final class zzjq {
    private static final zzxr zza;
    private static final zzxr zzb;
    private static final zzoa<zzjl, zzos> zzc;
    private static final zznw<zzos> zzd;
    private static final zzmx<zzjv, zzot> zze;
    private static final zzmt<zzot> zzf;
    private static final zzmx<zzjn, zzot> zzg;
    private static final zzmt<zzot> zzh;
    private static final zzmf<zzvt, zzjl.zzd> zzi;
    private static final zzmf<zzuc, zzjl.zzb> zzj;
    private static final zzmf<zztx, zzjl.zzc> zzk;
    private static final zzmf<zztj, zzjl.zze> zzl;

    static {
        zzxr zzxrVarZzb = zzpg.zzb("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey");
        zza = zzxrVarZzb;
        zzxr zzxrVarZzb2 = zzpg.zzb("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPublicKey");
        zzb = zzxrVarZzb2;
        zzc = zzoa.zza(new zzoc() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjp
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoc
            public final zzow zza(zzci zzciVar) {
                zzjl zzjlVar = (zzjl) zzciVar;
                return zzos.zzb((zzvd) ((zzaja) zzvd.zza().zza("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey").zza(((zzto) ((zzaja) zzto.zza().zza(zzjq.zzb(zzjlVar)).zzf())).zzi()).zza((zzvt) zzjq.zzi.zza(zzjlVar.zzg())).zzf()));
            }
        }, zzjl.class, zzos.class);
        zzd = zznw.zza(new zzny() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjs
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzny
            public final zzci zza(zzow zzowVar) {
                return zzjq.zzb((zzos) zzowVar);
            }
        }, zzxrVarZzb, zzos.class);
        zze = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjr
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                zzjv zzjvVar = (zzjv) zzbuVar;
                return zzot.zza("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPublicKey", zzjq.zza(zzjvVar).zzi(), zzux.zzb.ASYMMETRIC_PUBLIC, (zzvt) zzjq.zzi.zza(zzjvVar.zzb().zzg()), zzjvVar.zza());
            }
        }, zzjv.class, zzot.class);
        zzf = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzju
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzjq.zzd((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb2, zzot.class);
        zzg = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjt
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                return zzjq.zza((zzjn) zzbuVar, zzctVar);
            }
        }, zzjn.class, zzot.class);
        zzh = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjw
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzjq.zzc((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb, zzot.class);
        zzmi zzmiVarZza = zzmf.zza().zza(zzvt.RAW, zzjl.zzd.zzc).zza(zzvt.TINK, zzjl.zzd.zza);
        zzvt zzvtVar = zzvt.LEGACY;
        zzjl.zzd zzdVar = zzjl.zzd.zzb;
        zzi = zzmiVarZza.zza(zzvtVar, zzdVar).zza(zzvt.CRUNCHY, zzdVar).zza();
        zzj = zzmf.zza().zza(zzuc.SHA1, zzjl.zzb.zza).zza(zzuc.SHA224, zzjl.zzb.zzb).zza(zzuc.SHA256, zzjl.zzb.zzc).zza(zzuc.SHA384, zzjl.zzb.zzd).zza(zzuc.SHA512, zzjl.zzb.zze).zza();
        zzk = zzmf.zza().zza(zztx.NIST_P256, zzjl.zzc.zza).zza(zztx.NIST_P384, zzjl.zzc.zzb).zza(zztx.NIST_P521, zzjl.zzc.zzc).zza(zztx.CURVE25519, zzjl.zzc.zzd).zza();
        zzl = zzmf.zza().zza(zztj.UNCOMPRESSED, zzjl.zze.zzb).zza(zztj.COMPRESSED, zzjl.zze.zza).zza(zztj.DO_NOT_USE_CRUNCHY_UNCOMPRESSED, zzjl.zze.zzc).zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzjn zzc(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey")) {
            throw new IllegalArgumentException(a.m("Wrong type URL in call to EciesProtoSerialization.parsePrivateKey: ", zzotVar.zzf()));
        }
        try {
            zzts zztsVarZza = zzts.zza(zzotVar.zzd(), zzaip.zza());
            if (zztsVarZza.zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            zztt zzttVarZzd = zztsVarZza.zzd();
            zzjl zzjlVarZza = zza(zzotVar.zzc(), zzttVarZzd.zzb());
            return zzjlVarZza.zzd().equals(zzjl.zzc.zzd) ? zzjn.zza(zzjv.zza(zzjlVarZza, zzxr.zza(zzttVarZzd.zzf().zzg()), zzotVar.zze()), zzxt.zza(zztsVarZza.zze().zzg(), zzct.zza(zzctVar))) : zzjn.zza(zzjv.zza(zzjlVarZza, new ECPoint(zzmb.zza(zzttVarZzd.zzf().zzg()), zzmb.zza(zzttVarZzd.zzg().zzg())), zzotVar.zze()), zzxu.zza(zzmb.zza(zztsVarZza.zze().zzg()), zzct.zza(zzctVar)));
        } catch (zzajj | IllegalArgumentException unused) {
            throw new GeneralSecurityException("Parsing EcdsaPrivateKey failed");
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzjv zzd(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPublicKey")) {
            throw new IllegalArgumentException(a.m("Wrong type URL in call to EciesProtoSerialization.parsePublicKey: ", zzotVar.zzf()));
        }
        try {
            zztt zzttVarZza = zztt.zza(zzotVar.zzd(), zzaip.zza());
            if (zzttVarZza.zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            zzjl zzjlVarZza = zza(zzotVar.zzc(), zzttVarZza.zzb());
            if (!zzjlVarZza.zzd().equals(zzjl.zzc.zzd)) {
                return zzjv.zza(zzjlVarZza, new ECPoint(zzmb.zza(zzttVarZza.zzf().zzg()), zzmb.zza(zzttVarZza.zzg().zzg())), zzotVar.zze());
            }
            if (zzttVarZza.zzg().zze()) {
                return zzjv.zza(zzjlVarZza, zzxr.zza(zzttVarZza.zzf().zzg()), zzotVar.zze());
            }
            throw new GeneralSecurityException("Y must be empty for X25519 points");
        } catch (zzajj | IllegalArgumentException unused) {
            throw new GeneralSecurityException("Parsing EcdsaPublicKey failed");
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzjl zzb(zzos zzosVar) throws GeneralSecurityException {
        if (!zzosVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey")) {
            throw new IllegalArgumentException(a.m("Wrong type URL in call to EciesProtoSerialization.parseParameters: ", zzosVar.zza().zzf()));
        }
        try {
            return zza(zzosVar.zza().zzd(), zzto.zza(zzosVar.zza().zze(), zzaip.zza()).zzc());
        } catch (zzajj e) {
            throw new GeneralSecurityException("Parsing EciesParameters failed: ", e);
        }
    }

    private static int zza(zzjl.zzc zzcVar) throws GeneralSecurityException {
        if (zzjl.zzc.zza.equals(zzcVar)) {
            return 33;
        }
        if (zzjl.zzc.zzb.equals(zzcVar)) {
            return 49;
        }
        if (zzjl.zzc.zzc.equals(zzcVar)) {
            return 67;
        }
        throw new GeneralSecurityException("Unable to serialize CurveType ".concat(String.valueOf(zzcVar)));
    }

    private static zzjl zza(zzvt zzvtVar, zztp zztpVar) throws GeneralSecurityException {
        zzjl.zza zzaVarZza = zzjl.zzc().zza(zzi.zza(zzvtVar)).zza(zzk.zza(zztpVar.zzf().zzd())).zza(zzj.zza(zztpVar.zzf().zze())).zza(zzcv.zza(((zzvd) ((zzaja) zzvd.zza().zza(zztpVar.zzb().zzd().zzf()).zza(zzvt.RAW).zza(zztpVar.zzb().zzd().zze()).zzf())).zzj())).zza(zzxr.zza(zztpVar.zzf().zzf().zzg()));
        if (!zztpVar.zzf().zzd().equals(zztx.CURVE25519)) {
            zzaVarZza.zza(zzl.zza(zztpVar.zza()));
        } else if (!zztpVar.zza().equals(zztj.COMPRESSED)) {
            throw new GeneralSecurityException("For CURVE25519 EcPointFormat must be compressed");
        }
        return zzaVarZza.zza();
    }

    private static zztp zzb(zzjl zzjlVar) throws GeneralSecurityException {
        zztw.zza zzaVarZza = zztw.zza().zza((zztx) zzk.zza(zzjlVar.zzd())).zza((zzuc) zzj.zza(zzjlVar.zze()));
        if (zzjlVar.zzh() != null && zzjlVar.zzh().zza() > 0) {
            zzaVarZza.zza(zzahm.zza(zzjlVar.zzh().zzb()));
        }
        zztw zztwVar = (zztw) ((zzaja) zzaVarZza.zzf());
        try {
            zzvd zzvdVarZza = zzvd.zza(zzcv.zza(zzjlVar.zzb()), zzaip.zza());
            zztk zztkVar = (zztk) ((zzaja) zztk.zza().zza((zzvd) ((zzaja) zzvd.zza().zza(zzvdVarZza.zzf()).zza(zzvt.TINK).zza(zzvdVarZza.zze()).zzf())).zzf());
            zzjl.zze zzeVarZzf = zzjlVar.zzf();
            if (zzeVarZzf == null) {
                zzeVarZzf = zzjl.zze.zza;
            }
            return (zztp) ((zzaja) zztp.zzc().zza(zztwVar).zza(zztkVar).zza((zztj) zzl.zza(zzeVarZzf)).zzf());
        } catch (zzajj e) {
            throw new GeneralSecurityException("Parsing EciesParameters failed: ", e);
        }
    }

    public static /* synthetic */ zzot zza(zzjn zzjnVar, zzct zzctVar) throws GeneralSecurityException {
        zzts.zza zzaVarZza = zzts.zzb().zza(0).zza(zza((zzjv) zzjnVar.zzc()));
        if (zzjnVar.zzb().zzd().equals(zzjl.zzc.zzd)) {
            zzaVarZza.zza(zzahm.zza(zzjnVar.zze().zza(zzct.zza(zzctVar))));
        } else {
            zzaVarZza.zza(zzahm.zza(zzmb.zza(zzjnVar.zzd().zza(zzct.zza(zzctVar)), zza(zzjnVar.zzb().zzd()))));
        }
        return zzot.zza("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey", ((zzts) ((zzaja) zzaVarZza.zzf())).zzi(), zzux.zzb.ASYMMETRIC_PRIVATE, (zzvt) zzi.zza(zzjnVar.zzb().zzg()), zzjnVar.zza());
    }

    private static zztt zza(zzjv zzjvVar) throws GeneralSecurityException {
        if (zzjvVar.zzb().zzd().equals(zzjl.zzc.zzd)) {
            return (zztt) ((zzaja) zztt.zzc().zza(0).zza(zzb(zzjvVar.zzb())).zza(zzahm.zza(zzjvVar.zzc().zzb())).zzb(zzahm.zza).zzf());
        }
        int iZza = zza(zzjvVar.zzb().zzd());
        ECPoint eCPointZzd = zzjvVar.zzd();
        if (eCPointZzd != null) {
            return (zztt) ((zzaja) zztt.zzc().zza(0).zza(zzb(zzjvVar.zzb())).zza(zzahm.zza(zzmb.zza(eCPointZzd.getAffineX(), iZza))).zzb(zzahm.zza(zzmb.zza(eCPointZzd.getAffineY(), iZza))).zzf());
        }
        throw new GeneralSecurityException("NistCurvePoint was null for NIST curve");
    }

    public static void zza() {
        zznv zznvVarZza = zznv.zza();
        zznvVarZza.zza(zzc);
        zznvVarZza.zza(zzd);
        zznvVarZza.zza(zze);
        zznvVarZza.zza(zzf);
        zznvVarZza.zza(zzg);
        zznvVarZza.zza(zzh);
    }
}
