package e1;

import java.security.GeneralSecurityException;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: renamed from: e1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0361a implements l {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final J0.b f3975d = new J0.b(5);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final SecretKeySpec f3976a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f3977b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f3978c;

    public C0361a(byte[] bArr, int i4) throws GeneralSecurityException {
        if (!B1.a.g(2)) {
            throw new GeneralSecurityException("Can not use AES-CTR in FIPS-mode, as BoringCrypto module is not available.");
        }
        q.a(bArr.length);
        this.f3976a = new SecretKeySpec(bArr, "AES");
        int blockSize = ((Cipher) f3975d.get()).getBlockSize();
        this.f3978c = blockSize;
        if (i4 < 12 || i4 > blockSize) {
            throw new GeneralSecurityException("invalid IV size");
        }
        this.f3977b = i4;
    }

    public final void a(byte[] bArr, int i4, int i5, byte[] bArr2, int i6, byte[] bArr3, boolean z4) throws GeneralSecurityException {
        Cipher cipher = (Cipher) f3975d.get();
        byte[] bArr4 = new byte[this.f3978c];
        System.arraycopy(bArr3, 0, bArr4, 0, this.f3977b);
        IvParameterSpec ivParameterSpec = new IvParameterSpec(bArr4);
        SecretKeySpec secretKeySpec = this.f3976a;
        if (z4) {
            cipher.init(1, secretKeySpec, ivParameterSpec);
        } else {
            cipher.init(2, secretKeySpec, ivParameterSpec);
        }
        if (cipher.doFinal(bArr, i4, i5, bArr2, i6) != i5) {
            throw new GeneralSecurityException("stored output's length does not match input's length");
        }
    }
}
