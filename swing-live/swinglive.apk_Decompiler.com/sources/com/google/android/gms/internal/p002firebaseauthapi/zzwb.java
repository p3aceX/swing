package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import javax.crypto.AEADBadTagException;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class zzwb implements zzbh {
    private static final zzic.zza zza = zzic.zza.zza;
    private static final ThreadLocal<Cipher> zzb = new zzwe();
    private static final ThreadLocal<Cipher> zzc = new zzwd();
    private final byte[] zzd;
    private final byte[] zze;
    private final byte[] zzf;
    private final SecretKeySpec zzg;
    private final int zzh;

    private zzwb(byte[] bArr, int i4, byte[] bArr2) throws GeneralSecurityException {
        if (!zza.zza()) {
            throw new GeneralSecurityException("Can not use AES-EAX in FIPS-mode.");
        }
        if (i4 != 12 && i4 != 16) {
            throw new IllegalArgumentException("IV size should be either 12 or 16 bytes");
        }
        this.zzh = i4;
        zzxq.zza(bArr.length);
        SecretKeySpec secretKeySpec = new SecretKeySpec(bArr, "AES");
        this.zzg = secretKeySpec;
        Cipher cipher = zzb.get();
        cipher.init(1, secretKeySpec);
        byte[] bArrZza = zza(cipher.doFinal(new byte[16]));
        this.zzd = bArrZza;
        this.zze = zza(bArrZza);
        this.zzf = bArr2;
    }

    public static zzbh zza(zzdv zzdvVar) throws GeneralSecurityException {
        if (!zza.zza()) {
            throw new GeneralSecurityException("Can not use AES-EAX in FIPS-mode.");
        }
        if (zzdvVar.zzc().zzd() == 16) {
            return new zzwb(zzdvVar.zze().zza(zzbr.zza()), zzdvVar.zzc().zzb(), zzdvVar.zzd().zzb());
        }
        throw new GeneralSecurityException(S.d(zzdvVar.zzc().zzd(), "AesEaxJce only supports 16 byte tag size, not "));
    }

    private final byte[] zzc(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = (bArr.length - this.zzh) - 16;
        if (length < 0) {
            throw new GeneralSecurityException("ciphertext too short");
        }
        Cipher cipher = zzb.get();
        cipher.init(1, this.zzg);
        byte[] bArrZza = zza(cipher, 0, bArr, 0, this.zzh);
        byte[] bArr3 = bArr2 == null ? new byte[0] : bArr2;
        byte[] bArrZza2 = zza(cipher, 1, bArr3, 0, bArr3.length);
        byte[] bArrZza3 = zza(cipher, 2, bArr, this.zzh, length);
        int length2 = bArr.length - 16;
        byte b5 = 0;
        for (int i4 = 0; i4 < 16; i4++) {
            b5 = (byte) (b5 | (((bArr[length2 + i4] ^ bArrZza2[i4]) ^ bArrZza[i4]) ^ bArrZza3[i4]));
        }
        if (b5 != 0) {
            throw new AEADBadTagException("tag mismatch");
        }
        Cipher cipher2 = zzc.get();
        cipher2.init(1, this.zzg, new IvParameterSpec(bArrZza));
        return cipher2.doFinal(bArr, this.zzh, length);
    }

    private static byte[] zzd(byte[] bArr, byte[] bArr2) {
        int length = bArr.length;
        byte[] bArr3 = new byte[length];
        for (int i4 = 0; i4 < length; i4++) {
            bArr3[i4] = (byte) (bArr[i4] ^ bArr2[i4]);
        }
        return bArr3;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zzb(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = bArr.length;
        int i4 = this.zzh;
        if (length > 2147483631 - i4) {
            throw new GeneralSecurityException("plaintext too long");
        }
        byte[] bArr3 = new byte[bArr.length + i4 + 16];
        byte[] bArrZza = zzov.zza(i4);
        System.arraycopy(bArrZza, 0, bArr3, 0, this.zzh);
        Cipher cipher = zzb.get();
        cipher.init(1, this.zzg);
        byte[] bArrZza2 = zza(cipher, 0, bArrZza, 0, bArrZza.length);
        byte[] bArr4 = bArr2 == null ? new byte[0] : bArr2;
        byte[] bArrZza3 = zza(cipher, 1, bArr4, 0, bArr4.length);
        Cipher cipher2 = zzc.get();
        cipher2.init(1, this.zzg, new IvParameterSpec(bArrZza2));
        cipher2.doFinal(bArr, 0, bArr.length, bArr3, this.zzh);
        byte[] bArrZza4 = zza(cipher, 2, bArr3, this.zzh, bArr.length);
        int length2 = bArr.length + this.zzh;
        for (int i5 = 0; i5 < 16; i5++) {
            bArr3[length2 + i5] = (byte) ((bArrZza3[i5] ^ bArrZza2[i5]) ^ bArrZza4[i5]);
        }
        byte[] bArr5 = this.zzf;
        return bArr5.length == 0 ? bArr3 : zzwi.zza(bArr5, bArr3);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        byte[] bArr3 = this.zzf;
        if (bArr3.length == 0) {
            return zzc(bArr, bArr2);
        }
        if (zzpg.zza(bArr3, bArr)) {
            return zzc(Arrays.copyOfRange(bArr, this.zzf.length, bArr.length), bArr2);
        }
        throw new GeneralSecurityException("Decryption failed (OutputPrefix mismatch).");
    }

    private static byte[] zza(byte[] bArr) {
        byte[] bArr2 = new byte[16];
        int i4 = 0;
        while (i4 < 15) {
            int i5 = i4 + 1;
            bArr2[i4] = (byte) ((bArr[i4] << 1) ^ ((bArr[i5] & 255) >>> 7));
            i4 = i5;
        }
        bArr2[15] = (byte) (((bArr[0] >> 7) & 135) ^ (bArr[15] << 1));
        return bArr2;
    }

    private final byte[] zza(Cipher cipher, int i4, byte[] bArr, int i5, int i6) throws BadPaddingException, IllegalBlockSizeException {
        byte[] bArrZzd;
        byte[] bArr2 = new byte[16];
        bArr2[15] = (byte) i4;
        if (i6 == 0) {
            return cipher.doFinal(zzd(bArr2, this.zzd));
        }
        byte[] bArrDoFinal = cipher.doFinal(bArr2);
        int i7 = 0;
        while (i6 - i7 > 16) {
            for (int i8 = 0; i8 < 16; i8++) {
                bArrDoFinal[i8] = (byte) (bArrDoFinal[i8] ^ bArr[(i5 + i7) + i8]);
            }
            bArrDoFinal = cipher.doFinal(bArrDoFinal);
            i7 += 16;
        }
        byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, i7 + i5, i5 + i6);
        if (bArrCopyOfRange.length == 16) {
            bArrZzd = zzd(bArrCopyOfRange, this.zzd);
        } else {
            byte[] bArrCopyOf = Arrays.copyOf(this.zze, 16);
            for (int i9 = 0; i9 < bArrCopyOfRange.length; i9++) {
                bArrCopyOf[i9] = (byte) (bArrCopyOf[i9] ^ bArrCopyOfRange[i9]);
            }
            bArrCopyOf[bArrCopyOfRange.length] = (byte) (bArrCopyOf[bArrCopyOfRange.length] ^ 128);
            bArrZzd = bArrCopyOf;
        }
        return cipher.doFinal(zzd(bArrDoFinal, bArrZzd));
    }
}
