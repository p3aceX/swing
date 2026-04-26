package e1;

import a.AbstractC0184a;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.List;
import javax.crypto.AEADBadTagException;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import y0.C0747k;

/* JADX INFO: renamed from: e1.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0364d implements R0.c {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final List f3986c = Arrays.asList(64);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final byte[] f3987d = new byte[16];
    public static final byte[] e = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0747k f3988a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f3989b;

    public C0364d(byte[] bArr) throws GeneralSecurityException {
        if (!B1.a.f(1)) {
            throw new GeneralSecurityException("Can not use AES-SIV in FIPS-mode.");
        }
        if (!f3986c.contains(Integer.valueOf(bArr.length))) {
            throw new InvalidKeyException(B1.a.n(new StringBuilder("invalid key size: "), bArr.length, " bytes; key must have 64 bytes"));
        }
        byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 0, bArr.length / 2);
        this.f3989b = Arrays.copyOfRange(bArr, bArr.length / 2, bArr.length);
        this.f3988a = new C0747k(bArrCopyOfRange);
    }

    @Override // R0.c
    public final byte[] a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length > 2147483631) {
            throw new GeneralSecurityException("plaintext too long");
        }
        Cipher cipher = (Cipher) j.f3998b.f4000a.e("AES/CTR/NoPadding");
        byte[] bArrC = c(bArr2, bArr);
        byte[] bArr3 = (byte[]) bArrC.clone();
        bArr3[8] = (byte) (bArr3[8] & 127);
        bArr3[12] = (byte) (bArr3[12] & 127);
        cipher.init(1, new SecretKeySpec(this.f3989b, "AES"), new IvParameterSpec(bArr3));
        return AbstractC0367g.e(bArrC, cipher.doFinal(bArr));
    }

    @Override // R0.c
    public final byte[] b(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length < 16) {
            throw new GeneralSecurityException("Ciphertext too short.");
        }
        Cipher cipher = (Cipher) j.f3998b.f4000a.e("AES/CTR/NoPadding");
        byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 0, 16);
        byte[] bArr3 = (byte[]) bArrCopyOfRange.clone();
        bArr3[8] = (byte) (bArr3[8] & 127);
        bArr3[12] = (byte) (bArr3[12] & 127);
        cipher.init(2, new SecretKeySpec(this.f3989b, "AES"), new IvParameterSpec(bArr3));
        byte[] bArrCopyOfRange2 = Arrays.copyOfRange(bArr, 16, bArr.length);
        byte[] bArrDoFinal = cipher.doFinal(bArrCopyOfRange2);
        if (bArrCopyOfRange2.length == 0 && bArrDoFinal == null && "The Android Project".equals(System.getProperty("java.vendor"))) {
            bArrDoFinal = new byte[0];
        }
        if (MessageDigest.isEqual(bArrCopyOfRange, c(bArr2, bArrDoFinal))) {
            return bArrDoFinal;
        }
        throw new AEADBadTagException("Integrity check failed.");
    }

    public final byte[] c(byte[]... bArr) throws GeneralSecurityException {
        byte[] bArrY;
        int length = bArr.length;
        C0747k c0747k = this.f3988a;
        if (length == 0) {
            return c0747k.m(e, 16);
        }
        byte[] bArrM = c0747k.m(f3987d, 16);
        for (int i4 = 0; i4 < bArr.length - 1; i4++) {
            byte[] bArr2 = bArr[i4];
            if (bArr2 == null) {
                bArr2 = new byte[0];
            }
            bArrM = AbstractC0367g.Y(AbstractC0184a.n(bArrM), c0747k.m(bArr2, 16));
        }
        byte[] bArr3 = bArr[bArr.length - 1];
        if (bArr3.length >= 16) {
            if (bArr3.length < bArrM.length) {
                throw new IllegalArgumentException("xorEnd requires a.length >= b.length");
            }
            int length2 = bArr3.length - bArrM.length;
            bArrY = Arrays.copyOf(bArr3, bArr3.length);
            for (int i5 = 0; i5 < bArrM.length; i5++) {
                int i6 = length2 + i5;
                bArrY[i6] = (byte) (bArrY[i6] ^ bArrM[i5]);
            }
        } else {
            if (bArr3.length >= 16) {
                throw new IllegalArgumentException("x must be smaller than a block.");
            }
            byte[] bArrCopyOf = Arrays.copyOf(bArr3, 16);
            bArrCopyOf[bArr3.length] = -128;
            bArrY = AbstractC0367g.Y(bArrCopyOf, AbstractC0184a.n(bArrM));
        }
        return c0747k.m(bArrY, 16);
    }
}
