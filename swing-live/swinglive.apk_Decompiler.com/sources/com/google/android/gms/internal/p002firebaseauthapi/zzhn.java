package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.spec.AlgorithmParameterSpec;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class zzhn {
    private static final zzic.zza zza = zzic.zza.zzb;
    private static final ThreadLocal<Cipher> zzb = new zzhm();
    private final SecretKey zzc;
    private final boolean zzd;

    public zzhn(byte[] bArr, boolean z4) throws GeneralSecurityException {
        if (!zza.zza()) {
            throw new GeneralSecurityException("Can not use AES-GCM in FIPS-mode, as BoringCrypto module is not available.");
        }
        zzxq.zza(bArr.length);
        this.zzc = new SecretKeySpec(bArr, "AES");
        this.zzd = z4;
    }

    private static AlgorithmParameterSpec zza(byte[] bArr) {
        int length = bArr.length;
        Integer numZzb = zzpg.zzb();
        return (numZzb == null || numZzb.intValue() > 19) ? new GCMParameterSpec(128, bArr, 0, length) : new IvParameterSpec(bArr, 0, length);
    }

    public final byte[] zzb(byte[] bArr, byte[] bArr2, byte[] bArr3) throws GeneralSecurityException {
        if (bArr.length != 12) {
            throw new GeneralSecurityException("iv is wrong size");
        }
        if (bArr2.length > 2147483619) {
            throw new GeneralSecurityException("plaintext too long");
        }
        boolean z4 = this.zzd;
        byte[] bArr4 = new byte[z4 ? bArr2.length + 28 : bArr2.length + 16];
        if (z4) {
            System.arraycopy(bArr, 0, bArr4, 0, 12);
        }
        AlgorithmParameterSpec algorithmParameterSpecZza = zza(bArr);
        ThreadLocal<Cipher> threadLocal = zzb;
        threadLocal.get().init(1, this.zzc, algorithmParameterSpecZza);
        if (bArr3 != null && bArr3.length != 0) {
            threadLocal.get().updateAAD(bArr3);
        }
        int iDoFinal = threadLocal.get().doFinal(bArr2, 0, bArr2.length, bArr4, this.zzd ? 12 : 0);
        if (iDoFinal == bArr2.length + 16) {
            return bArr4;
        }
        throw new GeneralSecurityException(a.l("encryption failed; GCM tag must be 16 bytes, but got only ", iDoFinal - bArr2.length, " bytes"));
    }

    public final byte[] zza(byte[] bArr, byte[] bArr2, byte[] bArr3) throws GeneralSecurityException {
        if (bArr.length == 12) {
            boolean z4 = this.zzd;
            if (bArr2.length >= (z4 ? 28 : 16)) {
                if (z4 && !ByteBuffer.wrap(bArr).equals(ByteBuffer.wrap(bArr2, 0, 12))) {
                    throw new GeneralSecurityException("iv does not match prepended iv");
                }
                AlgorithmParameterSpec algorithmParameterSpecZza = zza(bArr);
                ThreadLocal<Cipher> threadLocal = zzb;
                threadLocal.get().init(2, this.zzc, algorithmParameterSpecZza);
                if (bArr3 != null && bArr3.length != 0) {
                    threadLocal.get().updateAAD(bArr3);
                }
                boolean z5 = this.zzd;
                return threadLocal.get().doFinal(bArr2, z5 ? 12 : 0, z5 ? bArr2.length - 12 : bArr2.length);
            }
            throw new GeneralSecurityException("ciphertext too short");
        }
        throw new GeneralSecurityException("iv is wrong size");
    }
}
