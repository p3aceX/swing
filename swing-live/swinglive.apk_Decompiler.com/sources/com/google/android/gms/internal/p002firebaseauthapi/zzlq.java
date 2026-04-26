package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import java.nio.charset.Charset;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzlq {
    private static final byte[] zzn;
    private static final byte[] zzo;
    private static final byte[] zzp;
    public static final byte[] zza = zza(1, 0);
    private static final byte[] zzm = zza(1, 2);
    public static final byte[] zzb = zza(2, 32);
    public static final byte[] zzc = zza(2, 16);
    public static final byte[] zzd = zza(2, 17);
    public static final byte[] zze = zza(2, 18);
    public static final byte[] zzf = zza(2, 1);
    public static final byte[] zzg = zza(2, 2);
    public static final byte[] zzh = zza(2, 3);
    public static final byte[] zzi = zza(2, 1);
    public static final byte[] zzj = zza(2, 2);
    public static final byte[] zzk = zza(2, 3);
    public static final byte[] zzl = new byte[0];

    static {
        Charset charset = zzpg.zza;
        zzn = "KEM".getBytes(charset);
        zzo = "HPKE".getBytes(charset);
        zzp = "HPKE-v1".getBytes(charset);
    }

    public static int zza(zzum zzumVar) throws GeneralSecurityException {
        int i4 = zzlp.zza[zzumVar.ordinal()];
        if (i4 == 1) {
            return 32;
        }
        if (i4 == 2) {
            return 48;
        }
        if (i4 == 3) {
            return 66;
        }
        if (i4 == 4) {
            return 32;
        }
        throw new GeneralSecurityException("Unrecognized HPKE KEM identifier");
    }

    public static int zzb(zzum zzumVar) throws GeneralSecurityException {
        int i4 = zzlp.zza[zzumVar.ordinal()];
        if (i4 == 1) {
            return 65;
        }
        if (i4 == 2) {
            return 97;
        }
        if (i4 == 3) {
            return 133;
        }
        if (i4 == 4) {
            return 32;
        }
        throw new GeneralSecurityException("Unrecognized HPKE KEM identifier");
    }

    public static zzwq zzc(zzum zzumVar) throws GeneralSecurityException {
        int i4 = zzlp.zza[zzumVar.ordinal()];
        if (i4 == 1) {
            return zzwq.NIST_P256;
        }
        if (i4 == 2) {
            return zzwq.NIST_P384;
        }
        if (i4 == 3) {
            return zzwq.NIST_P521;
        }
        throw new GeneralSecurityException("Unrecognized NIST HPKE KEM identifier");
    }

    public static void zza(zzus zzusVar) throws GeneralSecurityException {
        if (zzusVar.zzc() != zzum.KEM_UNKNOWN && zzusVar.zzc() != zzum.UNRECOGNIZED) {
            if (zzusVar.zzb() != zzuk.KDF_UNKNOWN && zzusVar.zzb() != zzuk.UNRECOGNIZED) {
                if (zzusVar.zza() == zzuj.AEAD_UNKNOWN || zzusVar.zza() == zzuj.UNRECOGNIZED) {
                    throw new GeneralSecurityException(a.m("Invalid AEAD param: ", zzusVar.zza().name()));
                }
                return;
            }
            throw new GeneralSecurityException(a.m("Invalid KDF param: ", zzusVar.zzb().name()));
        }
        throw new GeneralSecurityException(a.m("Invalid KEM param: ", zzusVar.zzc().name()));
    }

    public static byte[] zza(byte[] bArr, byte[] bArr2, byte[] bArr3) {
        return zzwi.zza(zzo, bArr, bArr2, bArr3);
    }

    private static byte[] zza(int i4, int i5) {
        byte[] bArr = new byte[i4];
        for (int i6 = 0; i6 < i4; i6++) {
            bArr[i6] = (byte) (i5 >> (((i4 - i6) - 1) * 8));
        }
        return bArr;
    }

    public static byte[] zza(byte[] bArr) {
        return zzwi.zza(zzn, bArr);
    }

    public static byte[] zza(String str, byte[] bArr, byte[] bArr2) {
        return zzwi.zza(zzp, bArr2, str.getBytes(zzpg.zza), bArr);
    }

    public static byte[] zza(String str, byte[] bArr, byte[] bArr2, int i4) {
        return zzwi.zza(zza(2, i4), zzp, bArr2, str.getBytes(zzpg.zza), bArr);
    }
}
