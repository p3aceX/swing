package androidx.datastore.preferences.protobuf;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0200k extends H0.a {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final Logger f2997n = Logger.getLogger(C0200k.class.getName());

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final boolean f2998o = h0.e;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public D f2999i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final byte[] f3000j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final int f3001k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f3002l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final I.o0 f3003m;

    public C0200k(I.o0 o0Var, int i4) {
        if (i4 < 0) {
            throw new IllegalArgumentException("bufferSize must be >= 0");
        }
        int iMax = Math.max(i4, 20);
        this.f3000j = new byte[iMax];
        this.f3001k = iMax;
        this.f3003m = o0Var;
    }

    public static int t0(int i4, C0196g c0196g) {
        int iV0 = v0(i4);
        int size = c0196g.size();
        return w0(size) + size + iV0;
    }

    public static int u0(String str) {
        int length;
        try {
            length = k0.a(str);
        } catch (j0 unused) {
            length = str.getBytes(AbstractC0211w.f3035a).length;
        }
        return w0(length) + length;
    }

    public static int v0(int i4) {
        return w0(i4 << 3);
    }

    public static int w0(int i4) {
        return (352 - (Integer.numberOfLeadingZeros(i4) * 9)) >>> 6;
    }

    public static int x0(long j4) {
        return (640 - (Long.numberOfLeadingZeros(j4) * 9)) >>> 6;
    }

    public final void A0(byte b5) throws IOException {
        if (this.f3002l == this.f3001k) {
            y0();
        }
        int i4 = this.f3002l;
        this.f3002l = i4 + 1;
        this.f3000j[i4] = b5;
    }

    public final void B0(byte[] bArr, int i4, int i5) throws IOException {
        int i6 = this.f3002l;
        int i7 = this.f3001k;
        int i8 = i7 - i6;
        byte[] bArr2 = this.f3000j;
        if (i8 >= i5) {
            System.arraycopy(bArr, i4, bArr2, i6, i5);
            this.f3002l += i5;
            return;
        }
        System.arraycopy(bArr, i4, bArr2, i6, i8);
        int i9 = i4 + i8;
        int i10 = i5 - i8;
        this.f3002l = i7;
        y0();
        if (i10 > i7) {
            this.f3003m.write(bArr, i9, i10);
        } else {
            System.arraycopy(bArr, i9, bArr2, 0, i10);
            this.f3002l = i10;
        }
    }

    public final void C0(int i4, boolean z4) throws IOException {
        z0(11);
        q0(i4, 0);
        byte b5 = z4 ? (byte) 1 : (byte) 0;
        int i5 = this.f3002l;
        this.f3002l = i5 + 1;
        this.f3000j[i5] = b5;
    }

    public final void D0(int i4, C0196g c0196g) {
        O0(i4, 2);
        E0(c0196g);
    }

    public final void E0(C0196g c0196g) throws IOException {
        Q0(c0196g.size());
        l0(c0196g.f2971b, c0196g.j(), c0196g.size());
    }

    public final void F0(int i4, int i5) {
        z0(14);
        q0(i4, 5);
        o0(i5);
    }

    public final void G0(int i4) throws IOException {
        z0(4);
        o0(i4);
    }

    public final void H0(int i4, long j4) {
        z0(18);
        q0(i4, 1);
        p0(j4);
    }

    public final void I0(long j4) throws IOException {
        z0(8);
        p0(j4);
    }

    public final void J0(int i4, int i5) throws IOException {
        z0(20);
        q0(i4, 0);
        if (i5 >= 0) {
            r0(i5);
        } else {
            s0(i5);
        }
    }

    public final void K0(int i4) throws IOException {
        if (i4 >= 0) {
            Q0(i4);
        } else {
            S0(i4);
        }
    }

    public final void L0(int i4, AbstractC0190a abstractC0190a, U u4) throws IOException {
        O0(i4, 2);
        Q0(abstractC0190a.a(u4));
        u4.g(abstractC0190a, this.f2999i);
    }

    public final void M0(int i4, String str) throws IOException {
        O0(i4, 2);
        N0(str);
    }

    public final void N0(String str) throws IOException {
        try {
            int length = str.length() * 3;
            int iW0 = w0(length);
            int i4 = iW0 + length;
            int i5 = this.f3001k;
            if (i4 > i5) {
                byte[] bArr = new byte[length];
                int iC = k0.f3004a.C(str, bArr, 0, length);
                Q0(iC);
                B0(bArr, 0, iC);
                return;
            }
            if (i4 > i5 - this.f3002l) {
                y0();
            }
            int iW02 = w0(str.length());
            int i6 = this.f3002l;
            byte[] bArr2 = this.f3000j;
            try {
                try {
                    if (iW02 == iW0) {
                        int i7 = i6 + iW02;
                        this.f3002l = i7;
                        int iC2 = k0.f3004a.C(str, bArr2, i7, i5 - i7);
                        this.f3002l = i6;
                        r0((iC2 - i6) - iW02);
                        this.f3002l = iC2;
                    } else {
                        int iA = k0.a(str);
                        r0(iA);
                        this.f3002l = k0.f3004a.C(str, bArr2, this.f3002l, iA);
                    }
                } catch (j0 e) {
                    this.f3002l = i6;
                    throw e;
                }
            } catch (ArrayIndexOutOfBoundsException e4) {
                throw new io.ktor.utils.io.E((IndexOutOfBoundsException) e4);
            }
        } catch (j0 e5) {
            f2997n.log(Level.WARNING, "Converting ill-formed UTF-16. Your Protocol Buffer will not round trip correctly!", (Throwable) e5);
            byte[] bytes = str.getBytes(AbstractC0211w.f3035a);
            try {
                Q0(bytes.length);
                l0(bytes, 0, bytes.length);
            } catch (IndexOutOfBoundsException e6) {
                throw new io.ktor.utils.io.E(e6);
            }
        }
    }

    public final void O0(int i4, int i5) {
        Q0((i4 << 3) | i5);
    }

    public final void P0(int i4, int i5) throws IOException {
        z0(20);
        q0(i4, 0);
        r0(i5);
    }

    public final void Q0(int i4) throws IOException {
        z0(5);
        r0(i4);
    }

    public final void R0(int i4, long j4) {
        z0(20);
        q0(i4, 0);
        s0(j4);
    }

    public final void S0(long j4) throws IOException {
        z0(10);
        s0(j4);
    }

    @Override // H0.a
    public final void l0(byte[] bArr, int i4, int i5) throws IOException {
        B0(bArr, i4, i5);
    }

    public final void o0(int i4) {
        int i5 = this.f3002l;
        int i6 = i5 + 1;
        this.f3002l = i6;
        byte[] bArr = this.f3000j;
        bArr[i5] = (byte) (i4 & 255);
        int i7 = i5 + 2;
        this.f3002l = i7;
        bArr[i6] = (byte) ((i4 >> 8) & 255);
        int i8 = i5 + 3;
        this.f3002l = i8;
        bArr[i7] = (byte) ((i4 >> 16) & 255);
        this.f3002l = i5 + 4;
        bArr[i8] = (byte) ((i4 >> 24) & 255);
    }

    public final void p0(long j4) {
        int i4 = this.f3002l;
        int i5 = i4 + 1;
        this.f3002l = i5;
        byte[] bArr = this.f3000j;
        bArr[i4] = (byte) (j4 & 255);
        int i6 = i4 + 2;
        this.f3002l = i6;
        bArr[i5] = (byte) ((j4 >> 8) & 255);
        int i7 = i4 + 3;
        this.f3002l = i7;
        bArr[i6] = (byte) ((j4 >> 16) & 255);
        int i8 = i4 + 4;
        this.f3002l = i8;
        bArr[i7] = (byte) (255 & (j4 >> 24));
        int i9 = i4 + 5;
        this.f3002l = i9;
        bArr[i8] = (byte) (((int) (j4 >> 32)) & 255);
        int i10 = i4 + 6;
        this.f3002l = i10;
        bArr[i9] = (byte) (((int) (j4 >> 40)) & 255);
        int i11 = i4 + 7;
        this.f3002l = i11;
        bArr[i10] = (byte) (((int) (j4 >> 48)) & 255);
        this.f3002l = i4 + 8;
        bArr[i11] = (byte) (((int) (j4 >> 56)) & 255);
    }

    public final void q0(int i4, int i5) {
        r0((i4 << 3) | i5);
    }

    public final void r0(int i4) {
        boolean z4 = f2998o;
        byte[] bArr = this.f3000j;
        if (z4) {
            while ((i4 & (-128)) != 0) {
                int i5 = this.f3002l;
                this.f3002l = i5 + 1;
                h0.j(bArr, i5, (byte) ((i4 | 128) & 255));
                i4 >>>= 7;
            }
            int i6 = this.f3002l;
            this.f3002l = i6 + 1;
            h0.j(bArr, i6, (byte) i4);
            return;
        }
        while ((i4 & (-128)) != 0) {
            int i7 = this.f3002l;
            this.f3002l = i7 + 1;
            bArr[i7] = (byte) ((i4 | 128) & 255);
            i4 >>>= 7;
        }
        int i8 = this.f3002l;
        this.f3002l = i8 + 1;
        bArr[i8] = (byte) i4;
    }

    public final void s0(long j4) {
        boolean z4 = f2998o;
        byte[] bArr = this.f3000j;
        if (z4) {
            while ((j4 & (-128)) != 0) {
                int i4 = this.f3002l;
                this.f3002l = i4 + 1;
                h0.j(bArr, i4, (byte) ((((int) j4) | 128) & 255));
                j4 >>>= 7;
            }
            int i5 = this.f3002l;
            this.f3002l = i5 + 1;
            h0.j(bArr, i5, (byte) j4);
            return;
        }
        while ((j4 & (-128)) != 0) {
            int i6 = this.f3002l;
            this.f3002l = i6 + 1;
            bArr[i6] = (byte) ((((int) j4) | 128) & 255);
            j4 >>>= 7;
        }
        int i7 = this.f3002l;
        this.f3002l = i7 + 1;
        bArr[i7] = (byte) j4;
    }

    public final void y0() throws IOException {
        this.f3003m.write(this.f3000j, 0, this.f3002l);
        this.f3002l = 0;
    }

    public final void z0(int i4) throws IOException {
        if (this.f3001k - this.f3002l < i4) {
            y0();
        }
    }
}
