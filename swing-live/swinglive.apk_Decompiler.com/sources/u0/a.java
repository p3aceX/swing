package U0;

import J0.b;
import e1.p;
import e1.q;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.spec.AlgorithmParameterSpec;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class a implements R0.a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final b f2086b = new b(3);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final boolean f2087c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final SecretKeySpec f2088a;

    static {
        boolean z4;
        try {
            Class.forName("javax.crypto.spec.GCMParameterSpec");
            z4 = true;
        } catch (ClassNotFoundException unused) {
            z4 = false;
        }
        f2087c = z4;
    }

    public a(byte[] bArr) throws InvalidAlgorithmParameterException {
        q.a(bArr.length);
        this.f2088a = new SecretKeySpec(bArr, "AES");
    }

    public static AlgorithmParameterSpec c(byte[] bArr, int i4) throws GeneralSecurityException {
        if (f2087c) {
            return new GCMParameterSpec(128, bArr, 0, i4);
        }
        if ("The Android Project".equals(System.getProperty("java.vendor"))) {
            return new IvParameterSpec(bArr, 0, i4);
        }
        throw new GeneralSecurityException("cannot use AES-GCM: javax.crypto.spec.GCMParameterSpec not found");
    }

    @Override // R0.a
    public final byte[] a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length > 2147483619) {
            throw new GeneralSecurityException("plaintext too long");
        }
        byte[] bArr3 = new byte[bArr.length + 28];
        byte[] bArrA = p.a(12);
        System.arraycopy(bArrA, 0, bArr3, 0, 12);
        AlgorithmParameterSpec algorithmParameterSpecC = c(bArrA, bArrA.length);
        b bVar = f2086b;
        ((Cipher) bVar.get()).init(1, this.f2088a, algorithmParameterSpecC);
        if (bArr2 != null && bArr2.length != 0) {
            ((Cipher) bVar.get()).updateAAD(bArr2);
        }
        int iDoFinal = ((Cipher) bVar.get()).doFinal(bArr, 0, bArr.length, bArr3, 12);
        if (iDoFinal == bArr.length + 16) {
            return bArr3;
        }
        throw new GeneralSecurityException(B1.a.l("encryption failed; GCM tag must be 16 bytes, but got only ", iDoFinal - bArr.length, " bytes"));
    }

    @Override // R0.a
    public final byte[] b(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length < 28) {
            throw new GeneralSecurityException("ciphertext too short");
        }
        AlgorithmParameterSpec algorithmParameterSpecC = c(bArr, 12);
        b bVar = f2086b;
        ((Cipher) bVar.get()).init(2, this.f2088a, algorithmParameterSpecC);
        if (bArr2 != null && bArr2.length != 0) {
            ((Cipher) bVar.get()).updateAAD(bArr2);
        }
        return ((Cipher) bVar.get()).doFinal(bArr, 12, bArr.length - 12);
    }
}
