package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Collection;
import javax.crypto.AEADBadTagException;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class zzwf implements zzbq {
    private static final zzic.zza zza = zzic.zza.zza;
    private static final Collection<Integer> zzb = Arrays.asList(64);
    private static final byte[] zzc = new byte[16];
    private static final byte[] zzd = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};
    private final zzxj zze;
    private final byte[] zzf;
    private final byte[] zzg;

    private zzwf(byte[] bArr, zzxr zzxrVar) throws GeneralSecurityException {
        if (!zza.zza()) {
            throw new GeneralSecurityException("Can not use AES-SIV in FIPS-mode.");
        }
        if (!zzb.contains(Integer.valueOf(bArr.length))) {
            throw new InvalidKeyException(a.l("invalid key size: ", bArr.length, " bytes; key must have 64 bytes"));
        }
        byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 0, bArr.length / 2);
        this.zzf = Arrays.copyOfRange(bArr, bArr.length / 2, bArr.length);
        this.zze = new zzxj(bArrCopyOfRange);
        this.zzg = zzxrVar.zzb();
    }

    public static zzbq zza(zzij zzijVar) {
        return new zzwf(zzijVar.zze().zza(zzbr.zza()), zzijVar.zzd());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbq
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        byte[] bArrZza;
        int length = bArr.length;
        byte[] bArr3 = this.zzg;
        if (length >= bArr3.length + 16) {
            if (zzpg.zza(bArr3, bArr)) {
                Cipher cipherZza = zzwr.zza.zza("AES/CTR/NoPadding");
                byte[] bArr4 = this.zzg;
                byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, bArr4.length, bArr4.length + 16);
                byte[] bArr5 = (byte[]) bArrCopyOfRange.clone();
                bArr5[8] = (byte) (bArr5[8] & 127);
                bArr5[12] = (byte) (bArr5[12] & 127);
                cipherZza.init(2, new SecretKeySpec(this.zzf, "AES"), new IvParameterSpec(bArr5));
                byte[] bArrCopyOfRange2 = Arrays.copyOfRange(bArr, this.zzg.length + 16, bArr.length);
                byte[] bArrDoFinal = cipherZza.doFinal(bArrCopyOfRange2);
                if (bArrCopyOfRange2.length == 0 && bArrDoFinal == null && zzxn.zza()) {
                    bArrDoFinal = new byte[0];
                }
                byte[][] bArr6 = {bArr2, bArrDoFinal};
                byte[] bArrZza2 = this.zze.zza(zzc, 16);
                for (int i4 = 0; i4 <= 0; i4++) {
                    byte[] bArr7 = bArr6[i4];
                    if (bArr7 == null) {
                        bArr7 = new byte[0];
                    }
                    bArrZza2 = zzwi.zza(zzrb.zzb(bArrZza2), this.zze.zza(bArr7, 16));
                }
                byte[] bArr8 = bArr6[1];
                if (bArr8.length >= 16) {
                    if (bArr8.length >= bArrZza2.length) {
                        int length2 = bArr8.length - bArrZza2.length;
                        bArrZza = Arrays.copyOf(bArr8, bArr8.length);
                        for (int i5 = 0; i5 < bArrZza2.length; i5++) {
                            int i6 = length2 + i5;
                            bArrZza[i6] = (byte) (bArrZza[i6] ^ bArrZza2[i5]);
                        }
                    } else {
                        throw new IllegalArgumentException("xorEnd requires a.length >= b.length");
                    }
                } else {
                    bArrZza = zzwi.zza(zzrb.zza(bArr8), zzrb.zzb(bArrZza2));
                }
                if (MessageDigest.isEqual(bArrCopyOfRange, this.zze.zza(bArrZza, 16))) {
                    return bArrDoFinal;
                }
                throw new AEADBadTagException("Integrity check failed.");
            }
            throw new GeneralSecurityException("Decryption failed (OutputPrefix mismatch).");
        }
        throw new GeneralSecurityException("Ciphertext too short.");
    }
}
