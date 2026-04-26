package e1;

import c1.InterfaceC0250a;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.MessageDigest;

/* JADX INFO: loaded from: classes.dex */
public final class o implements R0.j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final InterfaceC0250a f4006a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f4007b;

    public o(InterfaceC0250a interfaceC0250a, int i4) throws InvalidAlgorithmParameterException {
        this.f4006a = interfaceC0250a;
        this.f4007b = i4;
        if (i4 < 10) {
            throw new InvalidAlgorithmParameterException("tag size too small, need at least 10 bytes");
        }
        interfaceC0250a.m(new byte[0], i4);
    }

    @Override // R0.j
    public final void a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (!MessageDigest.isEqual(b(bArr2), bArr)) {
            throw new GeneralSecurityException("invalid MAC");
        }
    }

    @Override // R0.j
    public final byte[] b(byte[] bArr) {
        return this.f4006a.m(bArr, this.f4007b);
    }
}
