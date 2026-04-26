package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;

/* JADX INFO: loaded from: classes.dex */
final class zzku {
    public static zzwq zza(zztx zztxVar) throws GeneralSecurityException {
        int i4 = zzkt.zzb[zztxVar.ordinal()];
        if (i4 == 1) {
            return zzwq.NIST_P256;
        }
        if (i4 == 2) {
            return zzwq.NIST_P384;
        }
        if (i4 == 3) {
            return zzwq.NIST_P521;
        }
        throw new GeneralSecurityException("unknown curve type: ".concat(String.valueOf(zztxVar)));
    }

    public static zzwp zza(zztj zztjVar) throws GeneralSecurityException {
        int i4 = zzkt.zzc[zztjVar.ordinal()];
        if (i4 == 1) {
            return zzwp.UNCOMPRESSED;
        }
        if (i4 == 2) {
            return zzwp.DO_NOT_USE_CRUNCHY_UNCOMPRESSED;
        }
        if (i4 == 3) {
            return zzwp.COMPRESSED;
        }
        throw new GeneralSecurityException("unknown point format: ".concat(String.valueOf(zztjVar)));
    }

    public static String zza(zzuc zzucVar) throws NoSuchAlgorithmException {
        int i4 = zzkt.zza[zzucVar.ordinal()];
        if (i4 == 1) {
            return "HmacSha1";
        }
        if (i4 == 2) {
            return "HmacSha224";
        }
        if (i4 == 3) {
            return "HmacSha256";
        }
        if (i4 == 4) {
            return "HmacSha384";
        }
        if (i4 == 5) {
            return "HmacSha512";
        }
        throw new NoSuchAlgorithmException("hash unsupported for HMAC: ".concat(String.valueOf(zzucVar)));
    }

    public static void zza(zztp zztpVar) throws GeneralSecurityException {
        zzwn.zza(zza(zztpVar.zzf().zzd()));
        zza(zztpVar.zzf().zze());
        if (zztpVar.zza() != zztj.UNKNOWN_FORMAT) {
            zzcu.zza(zztpVar.zzb().zzd());
            return;
        }
        throw new GeneralSecurityException("unknown EC point format");
    }
}
