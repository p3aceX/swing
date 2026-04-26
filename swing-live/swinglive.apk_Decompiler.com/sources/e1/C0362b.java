package e1;

import java.security.GeneralSecurityException;
import java.util.Arrays;
import javax.crypto.AEADBadTagException;
import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: renamed from: e1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0362b implements R0.a {
    public static final J0.b e = new J0.b(6);

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final J0.b f3979f = new J0.b(7);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f3980a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f3981b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final SecretKeySpec f3982c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f3983d;

    public C0362b(byte[] bArr, int i4) throws GeneralSecurityException {
        if (!B1.a.f(1)) {
            throw new GeneralSecurityException("Can not use AES-EAX in FIPS-mode.");
        }
        if (i4 != 12 && i4 != 16) {
            throw new IllegalArgumentException("IV size should be either 12 or 16 bytes");
        }
        this.f3983d = i4;
        q.a(bArr.length);
        SecretKeySpec secretKeySpec = new SecretKeySpec(bArr, "AES");
        this.f3982c = secretKeySpec;
        Cipher cipher = (Cipher) e.get();
        cipher.init(1, secretKeySpec);
        byte[] bArrC = c(cipher.doFinal(new byte[16]));
        this.f3980a = bArrC;
        this.f3981b = c(bArrC);
    }

    public static byte[] c(byte[] bArr) {
        byte[] bArr2 = new byte[16];
        int i4 = 0;
        while (i4 < 15) {
            int i5 = i4 + 1;
            bArr2[i4] = (byte) (((bArr[i4] << 1) ^ ((bArr[i5] & 255) >>> 7)) & 255);
            i4 = i5;
        }
        bArr2[15] = (byte) (((bArr[0] >> 7) & 135) ^ (bArr[15] << 1));
        return bArr2;
    }

    public static byte[] e(byte[] bArr, byte[] bArr2) {
        int length = bArr.length;
        byte[] bArr3 = new byte[length];
        for (int i4 = 0; i4 < length; i4++) {
            bArr3[i4] = (byte) (bArr[i4] ^ bArr2[i4]);
        }
        return bArr3;
    }

    @Override // R0.a
    public final byte[] a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = bArr.length;
        int i4 = this.f3983d;
        if (length > 2147483631 - i4) {
            throw new GeneralSecurityException("plaintext too long");
        }
        byte[] bArr3 = new byte[bArr.length + i4 + 16];
        byte[] bArrA = p.a(i4);
        System.arraycopy(bArrA, 0, bArr3, 0, i4);
        Cipher cipher = (Cipher) e.get();
        SecretKeySpec secretKeySpec = this.f3982c;
        cipher.init(1, secretKeySpec);
        byte[] bArrD = d(cipher, 0, bArrA, 0, bArrA.length);
        byte[] bArr4 = bArr2 == null ? new byte[0] : bArr2;
        byte[] bArrD2 = d(cipher, 1, bArr4, 0, bArr4.length);
        Cipher cipher2 = (Cipher) f3979f.get();
        cipher2.init(1, secretKeySpec, new IvParameterSpec(bArrD));
        cipher2.doFinal(bArr, 0, bArr.length, bArr3, this.f3983d);
        byte[] bArrD3 = d(cipher, 2, bArr3, this.f3983d, bArr.length);
        int length2 = bArr.length + i4;
        for (int i5 = 0; i5 < 16; i5++) {
            bArr3[length2 + i5] = (byte) ((bArrD2[i5] ^ bArrD[i5]) ^ bArrD3[i5]);
        }
        return bArr3;
    }

    @Override // R0.a
    public final byte[] b(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = bArr.length;
        int i4 = this.f3983d;
        int i5 = (length - i4) - 16;
        if (i5 < 0) {
            throw new GeneralSecurityException("ciphertext too short");
        }
        Cipher cipher = (Cipher) e.get();
        SecretKeySpec secretKeySpec = this.f3982c;
        cipher.init(1, secretKeySpec);
        byte[] bArrD = d(cipher, 0, bArr, 0, this.f3983d);
        byte[] bArr3 = bArr2 == null ? new byte[0] : bArr2;
        byte[] bArrD2 = d(cipher, 1, bArr3, 0, bArr3.length);
        byte[] bArrD3 = d(cipher, 2, bArr, this.f3983d, i5);
        int length2 = bArr.length - 16;
        byte b5 = 0;
        for (int i6 = 0; i6 < 16; i6++) {
            b5 = (byte) (b5 | (((bArr[length2 + i6] ^ bArrD2[i6]) ^ bArrD[i6]) ^ bArrD3[i6]));
        }
        if (b5 != 0) {
            throw new AEADBadTagException("tag mismatch");
        }
        Cipher cipher2 = (Cipher) f3979f.get();
        cipher2.init(1, secretKeySpec, new IvParameterSpec(bArrD));
        return cipher2.doFinal(bArr, i4, i5);
    }

    public final byte[] d(Cipher cipher, int i4, byte[] bArr, int i5, int i6) throws BadPaddingException, IllegalBlockSizeException {
        byte[] bArrCopyOf;
        byte[] bArr2 = new byte[16];
        bArr2[15] = (byte) i4;
        byte[] bArr3 = this.f3980a;
        if (i6 == 0) {
            return cipher.doFinal(e(bArr2, bArr3));
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
            bArrCopyOf = e(bArrCopyOfRange, bArr3);
        } else {
            bArrCopyOf = Arrays.copyOf(this.f3981b, 16);
            for (int i9 = 0; i9 < bArrCopyOfRange.length; i9++) {
                bArrCopyOf[i9] = (byte) (bArrCopyOf[i9] ^ bArrCopyOfRange[i9]);
            }
            bArrCopyOf[bArrCopyOfRange.length] = (byte) (bArrCopyOf[bArrCopyOfRange.length] ^ 128);
        }
        return cipher.doFinal(e(bArrDoFinal, bArrCopyOf));
    }
}
