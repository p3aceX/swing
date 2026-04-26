package Z0;

import X.N;
import b1.C0243a;
import d1.r0;
import e1.AbstractC0367g;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import java.util.Iterator;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class o implements R0.j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0747k f2587a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final N f2588b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final N f2589c;

    public o(C0747k c0747k) {
        this.f2587a = c0747k;
        boolean zIsEmpty = ((C0243a) c0747k.f6833d).f3270a.isEmpty();
        N n4 = Y0.o.f2493a;
        if (zIsEmpty) {
            this.f2588b = n4;
            this.f2589c = n4;
            return;
        }
        Y0.e eVar = (Y0.e) Y0.f.f2473b.f2475a.get();
        eVar = eVar == null ? Y0.f.f2474c : eVar;
        Y0.o.a(c0747k);
        eVar.getClass();
        this.f2588b = n4;
        this.f2589c = n4;
    }

    @Override // R0.j
    public final void a(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = bArr.length;
        N n4 = this.f2589c;
        if (length <= 5) {
            n4.getClass();
            throw new GeneralSecurityException("tag too short");
        }
        byte[] bArrCopyOf = Arrays.copyOf(bArr, 5);
        byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 5, bArr.length);
        C0747k c0747k = this.f2587a;
        for (R0.l lVar : c0747k.I(bArrCopyOf)) {
            try {
                ((R0.j) lVar.f1696b).a(bArrCopyOfRange, lVar.e.equals(r0.LEGACY) ? AbstractC0367g.e(bArr2, p.f2591b) : bArr2);
                n4.getClass();
                return;
            } catch (GeneralSecurityException e) {
                p.f2590a.info("tag prefix matches a key, but cannot verify: " + e);
            }
        }
        Iterator it = c0747k.I(R0.b.f1679a).iterator();
        while (it.hasNext()) {
            try {
                ((R0.j) ((R0.l) it.next()).f1696b).a(bArr, bArr2);
                n4.getClass();
                return;
            } catch (GeneralSecurityException unused) {
            }
        }
        n4.getClass();
        throw new GeneralSecurityException("invalid MAC");
    }

    @Override // R0.j
    public final byte[] b(byte[] bArr) throws GeneralSecurityException {
        N n4 = this.f2588b;
        C0747k c0747k = this.f2587a;
        if (((R0.l) c0747k.f6832c).e.equals(r0.LEGACY)) {
            bArr = AbstractC0367g.e(bArr, p.f2591b);
        }
        try {
            byte[] bArr2 = ((R0.l) c0747k.f6832c).f1697c;
            byte[] bArrE = AbstractC0367g.e(bArr2 == null ? null : Arrays.copyOf(bArr2, bArr2.length), ((R0.j) ((R0.l) c0747k.f6832c).f1696b).b(bArr));
            int i4 = ((R0.l) c0747k.f6832c).f1699f;
            n4.getClass();
            return bArrE;
        } catch (GeneralSecurityException e) {
            n4.getClass();
            throw e;
        }
    }
}
