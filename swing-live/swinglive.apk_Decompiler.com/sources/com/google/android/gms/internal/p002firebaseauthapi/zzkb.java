package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzjx;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzkb {
    private static final zzxr zza;
    private static final zzxr zzb;
    private static final zzoa<zzjx, zzos> zzc;
    private static final zznw<zzos> zzd;
    private static final zzmx<zzkk, zzot> zze;
    private static final zzmt<zzot> zzf;
    private static final zzmx<zzkc, zzot> zzg;
    private static final zzmt<zzot> zzh;
    private static final zzmf<zzvt, zzjx.zzf> zzi;
    private static final zzmf<zzum, zzjx.zzd> zzj;
    private static final zzmf<zzuk, zzjx.zze> zzk;
    private static final zzmf<zzuj, zzjx.zza> zzl;

    static {
        zzxr zzxrVarZzb = zzpg.zzb("type.googleapis.com/google.crypto.tink.HpkePrivateKey");
        zza = zzxrVarZzb;
        zzxr zzxrVarZzb2 = zzpg.zzb("type.googleapis.com/google.crypto.tink.HpkePublicKey");
        zzb = zzxrVarZzb2;
        zzc = zzoa.zza(new zzoc() { // from class: com.google.android.gms.internal.firebase-auth-api.zzke
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoc
            public final zzow zza(zzci zzciVar) {
                zzjx zzjxVar = (zzjx) zzciVar;
                return zzos.zzb((zzvd) ((zzaja) zzvd.zza().zza("type.googleapis.com/google.crypto.tink.HpkePrivateKey").zza(((zzuo) ((zzaja) zzuo.zza().zza(zzkb.zzb(zzjxVar)).zzf())).zzi()).zza((zzvt) zzkb.zzi.zza(zzjxVar.zzf())).zzf()));
            }
        }, zzjx.class, zzos.class);
        zzd = zznw.zza(new zzny() { // from class: com.google.android.gms.internal.firebase-auth-api.zzkd
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzny
            public final zzci zza(zzow zzowVar) {
                return zzkb.zzb((zzos) zzowVar);
            }
        }, zzxrVarZzb, zzos.class);
        zze = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzkg
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                zzkk zzkkVar = (zzkk) zzbuVar;
                return zzot.zza("type.googleapis.com/google.crypto.tink.HpkePublicKey", zzkb.zza(zzkkVar).zzi(), zzux.zzb.ASYMMETRIC_PUBLIC, (zzvt) zzkb.zzi.zza(zzkkVar.zzb().zzf()), zzkkVar.zza());
            }
        }, zzkk.class, zzot.class);
        zzf = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzkf
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzkb.zzd((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb2, zzot.class);
        zzg = zzmx.zza(new zzmz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzki
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmz
            public final zzow zza(zzbu zzbuVar, zzct zzctVar) {
                zzkc zzkcVar = (zzkc) zzbuVar;
                return zzot.zza("type.googleapis.com/google.crypto.tink.HpkePrivateKey", ((zzut) ((zzaja) zzut.zzb().zza(0).zza(zzkb.zza((zzkk) zzkcVar.zzc())).zza(zzahm.zza(zzkcVar.zzd().zza(zzct.zza(zzctVar)))).zzf())).zzi(), zzux.zzb.ASYMMETRIC_PRIVATE, (zzvt) zzkb.zzi.zza(zzkcVar.zzb().zzf()), zzkcVar.zza());
            }
        }, zzkc.class, zzot.class);
        zzh = zzmt.zza(new zzmv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzkh
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmv
            public final zzbu zza(zzow zzowVar, zzct zzctVar) {
                return zzkb.zzc((zzot) zzowVar, zzctVar);
            }
        }, zzxrVarZzb, zzot.class);
        zzmi zzmiVarZza = zzmf.zza().zza(zzvt.RAW, zzjx.zzf.zzc).zza(zzvt.TINK, zzjx.zzf.zza);
        zzvt zzvtVar = zzvt.LEGACY;
        zzjx.zzf zzfVar = zzjx.zzf.zzb;
        zzi = zzmiVarZza.zza(zzvtVar, zzfVar).zza(zzvt.CRUNCHY, zzfVar).zza();
        zzj = zzmf.zza().zza(zzum.DHKEM_P256_HKDF_SHA256, zzjx.zzd.zza).zza(zzum.DHKEM_P384_HKDF_SHA384, zzjx.zzd.zzb).zza(zzum.DHKEM_P521_HKDF_SHA512, zzjx.zzd.zzc).zza(zzum.DHKEM_X25519_HKDF_SHA256, zzjx.zzd.zzd).zza();
        zzk = zzmf.zza().zza(zzuk.HKDF_SHA256, zzjx.zze.zza).zza(zzuk.HKDF_SHA384, zzjx.zze.zzb).zza(zzuk.HKDF_SHA512, zzjx.zze.zzc).zza();
        zzl = zzmf.zza().zza(zzuj.AES_128_GCM, zzjx.zza.zza).zza(zzuj.AES_256_GCM, zzjx.zza.zzb).zza(zzuj.CHACHA20_POLY1305, zzjx.zza.zzc).zza();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzkc zzc(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.HpkePrivateKey")) {
            throw new IllegalArgumentException(a.m("Wrong type URL in call to HpkeProtoSerialization.parsePrivateKey: ", zzotVar.zzf()));
        }
        try {
            zzut zzutVarZza = zzut.zza(zzotVar.zzd(), zzaip.zza());
            if (zzutVarZza.zza() != 0) {
                throw new GeneralSecurityException("Only version 0 keys are accepted");
            }
            zzuw zzuwVarZzd = zzutVarZza.zzd();
            return zzkc.zza(zzkk.zza(zza(zzotVar.zzc(), zzuwVarZzd.zzb()), zza(zzuwVarZzd.zzb().zzc(), zzuwVarZzd.zzf().zzg()), zzotVar.zze()), zzxt.zza(zzmb.zza(zzmb.zza(zzutVarZza.zze().zzg()), zzlq.zza(zzuwVarZzd.zzb().zzc())), zzct.zza(zzctVar)));
        } catch (zzajj unused) {
            throw new GeneralSecurityException("Parsing HpkePrivateKey failed");
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzkk zzd(zzot zzotVar, zzct zzctVar) throws GeneralSecurityException {
        if (!zzotVar.zzf().equals("type.googleapis.com/google.crypto.tink.HpkePublicKey")) {
            throw new IllegalArgumentException(a.m("Wrong type URL in call to HpkeProtoSerialization.parsePublicKey: ", zzotVar.zzf()));
        }
        try {
            zzuw zzuwVarZza = zzuw.zza(zzotVar.zzd(), zzaip.zza());
            if (zzuwVarZza.zza() == 0) {
                return zzkk.zza(zza(zzotVar.zzc(), zzuwVarZza.zzb()), zza(zzuwVarZza.zzb().zzc(), zzuwVarZza.zzf().zzg()), zzotVar.zze());
            }
            throw new GeneralSecurityException("Only version 0 keys are accepted");
        } catch (zzajj unused) {
            throw new GeneralSecurityException("Parsing HpkePublicKey failed");
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzjx zzb(zzos zzosVar) throws GeneralSecurityException {
        if (!zzosVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.HpkePrivateKey")) {
            throw new IllegalArgumentException(a.m("Wrong type URL in call to HpkeProtoSerialization.parseParameters: ", zzosVar.zza().zzf()));
        }
        try {
            return zza(zzosVar.zza().zzd(), zzuo.zza(zzosVar.zza().zze(), zzaip.zza()).zzc());
        } catch (zzajj e) {
            throw new GeneralSecurityException("Parsing HpkeParameters failed: ", e);
        }
    }

    private static zzjx zza(zzvt zzvtVar, zzus zzusVar) {
        return zzjx.zzc().zza(zzi.zza(zzvtVar)).zza(zzj.zza(zzusVar.zzc())).zza(zzk.zza(zzusVar.zzb())).zza(zzl.zza(zzusVar.zza())).zza();
    }

    private static zzus zzb(zzjx zzjxVar) {
        return (zzus) ((zzaja) zzus.zzd().zza((zzum) zzj.zza(zzjxVar.zze())).zza((zzuk) zzk.zza(zzjxVar.zzd())).zza((zzuj) zzl.zza(zzjxVar.zzb())).zzf());
    }

    private static zzuw zza(zzkk zzkkVar) {
        return (zzuw) ((zzaja) zzuw.zzc().zza(0).zza(zzb(zzkkVar.zzb())).zza(zzahm.zza(zzkkVar.zzc().zzb())).zzf());
    }

    private static zzxr zza(zzum zzumVar, byte[] bArr) {
        return zzxr.zza(zzmb.zza(zzmb.zza(bArr), zzlq.zzb(zzumVar)));
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
