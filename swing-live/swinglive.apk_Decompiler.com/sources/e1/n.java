package e1;

import c1.InterfaceC0250a;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class n implements InterfaceC0250a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final m f4002a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f4003b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final SecretKeySpec f4004c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f4005d;

    public n(String str, SecretKeySpec secretKeySpec) throws GeneralSecurityException {
        m mVar = new m(this);
        this.f4002a = mVar;
        if (!B1.a.g(2)) {
            throw new GeneralSecurityException("Can not use HMAC in FIPS-mode, as BoringCrypto module is not available.");
        }
        this.f4003b = str;
        this.f4004c = secretKeySpec;
        if (secretKeySpec.getEncoded().length < 16) {
            throw new InvalidAlgorithmParameterException("key size too small, need at least 16 bytes");
        }
        switch (str) {
            case "HMACSHA1":
                this.f4005d = 20;
                break;
            case "HMACSHA224":
                this.f4005d = 28;
                break;
            case "HMACSHA256":
                this.f4005d = 32;
                break;
            case "HMACSHA384":
                this.f4005d = 48;
                break;
            case "HMACSHA512":
                this.f4005d = 64;
                break;
            default:
                throw new NoSuchAlgorithmException("unknown Hmac algorithm: ".concat(str));
        }
        mVar.get();
    }

    @Override // c1.InterfaceC0250a
    public final byte[] m(byte[] bArr, int i4) throws InvalidAlgorithmParameterException {
        if (i4 > this.f4005d) {
            throw new InvalidAlgorithmParameterException("tag size too big");
        }
        m mVar = this.f4002a;
        ((Mac) mVar.get()).update(bArr);
        return Arrays.copyOf(((Mac) mVar.get()).doFinal(), i4);
    }
}
