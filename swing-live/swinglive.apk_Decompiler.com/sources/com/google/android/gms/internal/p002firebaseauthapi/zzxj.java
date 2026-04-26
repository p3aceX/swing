package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.util.Arrays;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class zzxj implements zzrv {
    private static final zzic.zza zza = zzic.zza.zza;
    private final SecretKey zzb;
    private byte[] zzc;
    private byte[] zzd;

    public zzxj(byte[] bArr) throws GeneralSecurityException {
        zzxq.zza(bArr.length);
        SecretKeySpec secretKeySpec = new SecretKeySpec(bArr, "AES");
        this.zzb = secretKeySpec;
        Cipher cipherZza = zza();
        cipherZza.init(1, secretKeySpec);
        byte[] bArrZzb = zzrb.zzb(cipherZza.doFinal(new byte[16]));
        this.zzc = bArrZzb;
        this.zzd = zzrb.zzb(bArrZzb);
    }

    private static Cipher zza() throws GeneralSecurityException {
        if (zza.zza()) {
            return zzwr.zza.zza("AES/ECB/NoPadding");
        }
        throw new GeneralSecurityException("Can not use AES-CMAC in FIPS-mode.");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzrv
    public final byte[] zza(byte[] bArr, int i4) throws GeneralSecurityException {
        byte[] bArrZza;
        if (i4 <= 16) {
            Cipher cipherZza = zza();
            cipherZza.init(1, this.zzb);
            int iMax = Math.max(1, (int) Math.ceil(((double) bArr.length) / 16.0d));
            if ((iMax << 4) == bArr.length) {
                bArrZza = zzwi.zza(bArr, (iMax - 1) << 4, this.zzc, 0, 16);
            } else {
                bArrZza = zzwi.zza(zzrb.zza(Arrays.copyOfRange(bArr, (iMax - 1) << 4, bArr.length)), this.zzd);
            }
            byte[] bArrDoFinal = new byte[16];
            for (int i5 = 0; i5 < iMax - 1; i5++) {
                bArrDoFinal = cipherZza.doFinal(zzwi.zza(bArrDoFinal, 0, bArr, i5 << 4, 16));
            }
            return Arrays.copyOf(cipherZza.doFinal(zzwi.zza(bArrZza, bArrDoFinal)), i4);
        }
        throw new InvalidAlgorithmParameterException("outputLength too large, max is 16 bytes");
    }
}
