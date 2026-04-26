package com.google.crypto.tink.shaded.protobuf;

import java.util.logging.Logger;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0306k extends H0.a {

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final Logger f3810m = Logger.getLogger(C0306k.class.getName());

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final boolean f3811n = o0.e;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public K f3812i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final byte[] f3813j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final int f3814k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f3815l;

    public C0306k(byte[] bArr, int i4) {
        if (((bArr.length - i4) | i4) < 0) {
            throw new IllegalArgumentException(String.format("Array range is invalid. Buffer.length=%d, offset=%d, length=%d", Integer.valueOf(bArr.length), 0, Integer.valueOf(i4)));
        }
        this.f3813j = bArr;
        this.f3815l = 0;
        this.f3814k = i4;
    }

    public static int o0(int i4, AbstractC0303h abstractC0303h) {
        return p0(abstractC0303h) + v0(i4);
    }

    public static int p0(AbstractC0303h abstractC0303h) {
        int size = abstractC0303h.size();
        return w0(size) + size;
    }

    public static int q0(int i4) {
        return v0(i4) + 4;
    }

    public static int r0(int i4) {
        return v0(i4) + 8;
    }

    public static int s0(int i4, AbstractC0296a abstractC0296a, c0 c0Var) {
        return abstractC0296a.b(c0Var) + (v0(i4) * 2);
    }

    public static int t0(int i4) {
        if (i4 >= 0) {
            return w0(i4);
        }
        return 10;
    }

    public static int u0(String str) {
        int length;
        try {
            length = r0.b(str);
        } catch (q0 unused) {
            length = str.getBytes(AbstractC0320z.f3839a).length;
        }
        return w0(length) + length;
    }

    public static int v0(int i4) {
        return w0(i4 << 3);
    }

    public static int w0(int i4) {
        if ((i4 & (-128)) == 0) {
            return 1;
        }
        if ((i4 & (-16384)) == 0) {
            return 2;
        }
        if (((-2097152) & i4) == 0) {
            return 3;
        }
        return (i4 & (-268435456)) == 0 ? 4 : 5;
    }

    public static int x0(long j4) {
        int i4;
        if (((-128) & j4) == 0) {
            return 1;
        }
        if (j4 < 0) {
            return 10;
        }
        if (((-34359738368L) & j4) != 0) {
            j4 >>>= 28;
            i4 = 6;
        } else {
            i4 = 2;
        }
        if (((-2097152) & j4) != 0) {
            i4 += 2;
            j4 >>>= 14;
        }
        return (j4 & (-16384)) != 0 ? i4 + 1 : i4;
    }

    public final void A0(int i4, int i5) throws io.ktor.utils.io.E {
        F0(i4, 5);
        B0(i5);
    }

    public final void B0(int i4) throws io.ktor.utils.io.E {
        try {
            byte[] bArr = this.f3813j;
            int i5 = this.f3815l;
            int i6 = i5 + 1;
            this.f3815l = i6;
            bArr[i5] = (byte) (i4 & 255);
            int i7 = i5 + 2;
            this.f3815l = i7;
            bArr[i6] = (byte) ((i4 >> 8) & 255);
            int i8 = i5 + 3;
            this.f3815l = i8;
            bArr[i7] = (byte) ((i4 >> 16) & 255);
            this.f3815l = i5 + 4;
            bArr[i8] = (byte) ((i4 >> 24) & 255);
        } catch (IndexOutOfBoundsException e) {
            throw new io.ktor.utils.io.E(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.f3815l), Integer.valueOf(this.f3814k), 1), e);
        }
    }

    public final void C0(int i4, long j4) throws io.ktor.utils.io.E {
        F0(i4, 1);
        D0(j4);
    }

    public final void D0(long j4) throws io.ktor.utils.io.E {
        try {
            byte[] bArr = this.f3813j;
            int i4 = this.f3815l;
            int i5 = i4 + 1;
            this.f3815l = i5;
            bArr[i4] = (byte) (((int) j4) & 255);
            int i6 = i4 + 2;
            this.f3815l = i6;
            bArr[i5] = (byte) (((int) (j4 >> 8)) & 255);
            int i7 = i4 + 3;
            this.f3815l = i7;
            bArr[i6] = (byte) (((int) (j4 >> 16)) & 255);
            int i8 = i4 + 4;
            this.f3815l = i8;
            bArr[i7] = (byte) (((int) (j4 >> 24)) & 255);
            int i9 = i4 + 5;
            this.f3815l = i9;
            bArr[i8] = (byte) (((int) (j4 >> 32)) & 255);
            int i10 = i4 + 6;
            this.f3815l = i10;
            bArr[i9] = (byte) (((int) (j4 >> 40)) & 255);
            int i11 = i4 + 7;
            this.f3815l = i11;
            bArr[i10] = (byte) (((int) (j4 >> 48)) & 255);
            this.f3815l = i4 + 8;
            bArr[i11] = (byte) (((int) (j4 >> 56)) & 255);
        } catch (IndexOutOfBoundsException e) {
            throw new io.ktor.utils.io.E(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.f3815l), Integer.valueOf(this.f3814k), 1), e);
        }
    }

    public final void E0(int i4) throws io.ktor.utils.io.E {
        if (i4 >= 0) {
            G0(i4);
        } else {
            I0(i4);
        }
    }

    public final void F0(int i4, int i5) throws io.ktor.utils.io.E {
        G0((i4 << 3) | i5);
    }

    public final void G0(int i4) throws io.ktor.utils.io.E {
        while (true) {
            int i5 = i4 & (-128);
            byte[] bArr = this.f3813j;
            if (i5 == 0) {
                int i6 = this.f3815l;
                this.f3815l = i6 + 1;
                bArr[i6] = (byte) i4;
                return;
            } else {
                try {
                    int i7 = this.f3815l;
                    this.f3815l = i7 + 1;
                    bArr[i7] = (byte) ((i4 & 127) | 128);
                    i4 >>>= 7;
                } catch (IndexOutOfBoundsException e) {
                    throw new io.ktor.utils.io.E(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.f3815l), Integer.valueOf(this.f3814k), 1), e);
                }
            }
            throw new io.ktor.utils.io.E(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.f3815l), Integer.valueOf(this.f3814k), 1), e);
        }
    }

    public final void H0(int i4, long j4) throws io.ktor.utils.io.E {
        F0(i4, 0);
        I0(j4);
    }

    public final void I0(long j4) throws io.ktor.utils.io.E {
        byte[] bArr = this.f3813j;
        boolean z4 = f3811n;
        int i4 = this.f3814k;
        if (z4 && i4 - this.f3815l >= 10) {
            while ((j4 & (-128)) != 0) {
                int i5 = this.f3815l;
                this.f3815l = i5 + 1;
                o0.k(bArr, i5, (byte) ((((int) j4) & 127) | 128));
                j4 >>>= 7;
            }
            int i6 = this.f3815l;
            this.f3815l = i6 + 1;
            o0.k(bArr, i6, (byte) j4);
            return;
        }
        while ((j4 & (-128)) != 0) {
            try {
                int i7 = this.f3815l;
                this.f3815l = i7 + 1;
                bArr[i7] = (byte) ((((int) j4) & 127) | 128);
                j4 >>>= 7;
            } catch (IndexOutOfBoundsException e) {
                throw new io.ktor.utils.io.E(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.f3815l), Integer.valueOf(i4), 1), e);
            }
        }
        int i8 = this.f3815l;
        this.f3815l = i8 + 1;
        bArr[i8] = (byte) j4;
    }

    public final void y0(byte b5) throws io.ktor.utils.io.E {
        try {
            byte[] bArr = this.f3813j;
            int i4 = this.f3815l;
            this.f3815l = i4 + 1;
            bArr[i4] = b5;
        } catch (IndexOutOfBoundsException e) {
            throw new io.ktor.utils.io.E(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.f3815l), Integer.valueOf(this.f3814k), 1), e);
        }
    }

    public final void z0(byte[] bArr, int i4, int i5) throws io.ktor.utils.io.E {
        try {
            System.arraycopy(bArr, i4, this.f3813j, this.f3815l, i5);
            this.f3815l += i5;
        } catch (IndexOutOfBoundsException e) {
            throw new io.ktor.utils.io.E(String.format("Pos: %d, limit: %d, len: %d", Integer.valueOf(this.f3815l), Integer.valueOf(this.f3814k), Integer.valueOf(i5)), e);
        }
    }
}
