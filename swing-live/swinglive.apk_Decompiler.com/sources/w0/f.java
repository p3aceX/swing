package W0;

import R0.l;
import X.N;
import Y0.o;
import b1.C0243a;
import e1.AbstractC0367g;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import java.util.Iterator;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class f implements R0.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0747k f2266a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final N f2267b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final N f2268c;

    public f(C0747k c0747k) {
        this.f2266a = c0747k;
        boolean zIsEmpty = ((C0243a) c0747k.f6833d).f3270a.isEmpty();
        N n4 = o.f2493a;
        if (zIsEmpty) {
            this.f2267b = n4;
            this.f2268c = n4;
            return;
        }
        Y0.e eVar = (Y0.e) Y0.f.f2473b.f2475a.get();
        eVar = eVar == null ? Y0.f.f2474c : eVar;
        o.a(c0747k);
        eVar.getClass();
        this.f2267b = n4;
        this.f2268c = n4;
    }

    @Override // R0.c
    public final byte[] a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        N n4 = this.f2267b;
        C0747k c0747k = this.f2266a;
        try {
            byte[] bArr3 = ((l) c0747k.f6832c).f1697c;
            byte[] bArrE = AbstractC0367g.e(bArr3 == null ? null : Arrays.copyOf(bArr3, bArr3.length), ((R0.c) ((l) c0747k.f6832c).f1696b).a(bArr, bArr2));
            int i4 = ((l) c0747k.f6832c).f1699f;
            n4.getClass();
            return bArrE;
        } catch (GeneralSecurityException e) {
            n4.getClass();
            throw e;
        }
    }

    @Override // R0.c
    public final byte[] b(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = bArr.length;
        C0747k c0747k = this.f2266a;
        N n4 = this.f2268c;
        if (length > 5) {
            byte[] bArrCopyOf = Arrays.copyOf(bArr, 5);
            byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 5, bArr.length);
            Iterator it = c0747k.I(bArrCopyOf).iterator();
            while (it.hasNext()) {
                try {
                    byte[] bArrB = ((R0.c) ((l) it.next()).f1696b).b(bArrCopyOfRange, bArr2);
                    n4.getClass();
                    return bArrB;
                } catch (GeneralSecurityException e) {
                    g.f2269a.info("ciphertext prefix matches a key, but cannot decrypt: " + e);
                }
            }
        }
        Iterator it2 = c0747k.I(R0.b.f1679a).iterator();
        while (it2.hasNext()) {
            try {
                byte[] bArrB2 = ((R0.c) ((l) it2.next()).f1696b).b(bArr, bArr2);
                n4.getClass();
                return bArrB2;
            } catch (GeneralSecurityException unused) {
            }
        }
        n4.getClass();
        throw new GeneralSecurityException("decryption failed");
    }
}
