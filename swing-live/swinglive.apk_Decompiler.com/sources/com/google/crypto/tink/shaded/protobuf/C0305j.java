package com.google.crypto.tink.shaded.protobuf;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.ArrayList;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0305j extends T0.d {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ByteArrayInputStream f3802c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final byte[] f3803d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f3804f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public int f3805g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f3806h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f3807i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public int f3808j = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;

    public C0305j(ByteArrayInputStream byteArrayInputStream) {
        Charset charset = AbstractC0320z.f3839a;
        this.f3802c = byteArrayInputStream;
        this.f3803d = new byte[4096];
        this.e = 0;
        this.f3805g = 0;
        this.f3807i = 0;
    }

    @Override // T0.d
    public final String A() throws B {
        int iM = M();
        byte[] bArr = this.f3803d;
        if (iM > 0) {
            int i4 = this.e;
            int i5 = this.f3805g;
            if (iM <= i4 - i5) {
                String str = new String(bArr, i5, iM, AbstractC0320z.f3839a);
                this.f3805g += iM;
                return str;
            }
        }
        if (iM == 0) {
            return "";
        }
        if (iM > this.e) {
            return new String(H(iM), AbstractC0320z.f3839a);
        }
        Q(iM);
        String str2 = new String(bArr, this.f3805g, iM, AbstractC0320z.f3839a);
        this.f3805g += iM;
        return str2;
    }

    @Override // T0.d
    public final String B() throws IOException {
        int iM = M();
        int i4 = this.f3805g;
        int i5 = this.e;
        int i6 = i5 - i4;
        byte[] bArrH = this.f3803d;
        if (iM <= i6 && iM > 0) {
            this.f3805g = i4 + iM;
        } else {
            if (iM == 0) {
                return "";
            }
            i4 = 0;
            if (iM <= i5) {
                Q(iM);
                this.f3805g = iM;
            } else {
                bArrH = H(iM);
            }
        }
        return r0.f3834a.v(bArrH, i4, iM);
    }

    @Override // T0.d
    public final int C() throws B {
        if (g()) {
            this.f3806h = 0;
            return 0;
        }
        int iM = M();
        this.f3806h = iM;
        if ((iM >>> 3) != 0) {
            return iM;
        }
        throw B.a();
    }

    @Override // T0.d
    public final int D() {
        return M();
    }

    @Override // T0.d
    public final long E() {
        return N();
    }

    public final byte[] H(int i4) throws IOException {
        byte[] bArrI = I(i4);
        if (bArrI != null) {
            return bArrI;
        }
        int i5 = this.f3805g;
        int i6 = this.e;
        int length = i6 - i5;
        this.f3807i += i6;
        this.f3805g = 0;
        this.e = 0;
        ArrayList<byte[]> arrayListJ = J(i4 - length);
        byte[] bArr = new byte[i4];
        System.arraycopy(this.f3803d, i5, bArr, 0, length);
        for (byte[] bArr2 : arrayListJ) {
            System.arraycopy(bArr2, 0, bArr, length, bArr2.length);
            length += bArr2.length;
        }
        return bArr;
    }

    public final byte[] I(int i4) throws IOException {
        if (i4 == 0) {
            return AbstractC0320z.f3840b;
        }
        if (i4 < 0) {
            throw B.e();
        }
        int i5 = this.f3807i;
        int i6 = this.f3805g;
        int i7 = i5 + i6 + i4;
        if (i7 - com.google.android.gms.common.api.f.API_PRIORITY_OTHER > 0) {
            throw new B("Protocol message was too large.  May be malicious.  Use CodedInputStream.setSizeLimit() to increase the size limit.");
        }
        int i8 = this.f3808j;
        if (i7 > i8) {
            R((i8 - i5) - i6);
            throw B.g();
        }
        int i9 = this.e - i6;
        int i10 = i4 - i9;
        ByteArrayInputStream byteArrayInputStream = this.f3802c;
        if (i10 >= 4096) {
            try {
                if (i10 > byteArrayInputStream.available()) {
                    return null;
                }
            } catch (B e) {
                e.f3723a = true;
                throw e;
            }
        }
        byte[] bArr = new byte[i4];
        System.arraycopy(this.f3803d, this.f3805g, bArr, 0, i9);
        this.f3807i += this.e;
        this.f3805g = 0;
        this.e = 0;
        while (i9 < i4) {
            try {
                int i11 = byteArrayInputStream.read(bArr, i9, i4 - i9);
                if (i11 == -1) {
                    throw B.g();
                }
                this.f3807i += i11;
                i9 += i11;
            } catch (B e4) {
                e4.f3723a = true;
                throw e4;
            }
        }
        return bArr;
    }

    public final ArrayList J(int i4) throws IOException {
        ArrayList arrayList = new ArrayList();
        while (i4 > 0) {
            int iMin = Math.min(i4, 4096);
            byte[] bArr = new byte[iMin];
            int i5 = 0;
            while (i5 < iMin) {
                int i6 = this.f3802c.read(bArr, i5, iMin - i5);
                if (i6 == -1) {
                    throw B.g();
                }
                this.f3807i += i6;
                i5 += i6;
            }
            i4 -= iMin;
            arrayList.add(bArr);
        }
        return arrayList;
    }

    public final int K() throws B {
        int i4 = this.f3805g;
        if (this.e - i4 < 4) {
            Q(4);
            i4 = this.f3805g;
        }
        this.f3805g = i4 + 4;
        byte[] bArr = this.f3803d;
        return ((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16);
    }

    public final long L() throws B {
        int i4 = this.f3805g;
        if (this.e - i4 < 8) {
            Q(8);
            i4 = this.f3805g;
        }
        this.f3805g = i4 + 8;
        byte[] bArr = this.f3803d;
        return ((((long) bArr[i4 + 7]) & 255) << 56) | (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48);
    }

    public final int M() {
        int i4;
        int i5 = this.f3805g;
        int i6 = this.e;
        if (i6 != i5) {
            int i7 = i5 + 1;
            byte[] bArr = this.f3803d;
            byte b5 = bArr[i5];
            if (b5 >= 0) {
                this.f3805g = i7;
                return b5;
            }
            if (i6 - i7 >= 9) {
                int i8 = i5 + 2;
                int i9 = (bArr[i7] << 7) ^ b5;
                if (i9 < 0) {
                    i4 = i9 ^ (-128);
                } else {
                    int i10 = i5 + 3;
                    int i11 = (bArr[i8] << 14) ^ i9;
                    if (i11 >= 0) {
                        i4 = i11 ^ 16256;
                    } else {
                        int i12 = i5 + 4;
                        int i13 = i11 ^ (bArr[i10] << 21);
                        if (i13 < 0) {
                            i4 = (-2080896) ^ i13;
                        } else {
                            i10 = i5 + 5;
                            byte b6 = bArr[i12];
                            int i14 = (i13 ^ (b6 << 28)) ^ 266354560;
                            if (b6 < 0) {
                                i12 = i5 + 6;
                                if (bArr[i10] < 0) {
                                    i10 = i5 + 7;
                                    if (bArr[i12] < 0) {
                                        i12 = i5 + 8;
                                        if (bArr[i10] < 0) {
                                            i10 = i5 + 9;
                                            if (bArr[i12] < 0) {
                                                int i15 = i5 + 10;
                                                if (bArr[i10] >= 0) {
                                                    i8 = i15;
                                                    i4 = i14;
                                                }
                                            }
                                        }
                                    }
                                }
                                i4 = i14;
                            }
                            i4 = i14;
                        }
                        i8 = i12;
                    }
                    i8 = i10;
                }
                this.f3805g = i8;
                return i4;
            }
        }
        return (int) O();
    }

    public final long N() {
        long j4;
        long j5;
        long j6;
        long j7;
        int i4 = this.f3805g;
        int i5 = this.e;
        if (i5 != i4) {
            int i6 = i4 + 1;
            byte[] bArr = this.f3803d;
            byte b5 = bArr[i4];
            if (b5 >= 0) {
                this.f3805g = i6;
                return b5;
            }
            if (i5 - i6 >= 9) {
                int i7 = i4 + 2;
                int i8 = (bArr[i6] << 7) ^ b5;
                if (i8 < 0) {
                    j4 = i8 ^ (-128);
                } else {
                    int i9 = i4 + 3;
                    int i10 = (bArr[i7] << 14) ^ i8;
                    if (i10 >= 0) {
                        j4 = i10 ^ 16256;
                        i7 = i9;
                    } else {
                        int i11 = i4 + 4;
                        int i12 = i10 ^ (bArr[i9] << 21);
                        if (i12 < 0) {
                            j7 = (-2080896) ^ i12;
                        } else {
                            long j8 = i12;
                            i7 = i4 + 5;
                            long j9 = j8 ^ (((long) bArr[i11]) << 28);
                            if (j9 >= 0) {
                                j6 = 266354560;
                            } else {
                                i11 = i4 + 6;
                                long j10 = j9 ^ (((long) bArr[i7]) << 35);
                                if (j10 < 0) {
                                    j5 = -34093383808L;
                                } else {
                                    i7 = i4 + 7;
                                    j9 = j10 ^ (((long) bArr[i11]) << 42);
                                    if (j9 >= 0) {
                                        j6 = 4363953127296L;
                                    } else {
                                        i11 = i4 + 8;
                                        j10 = j9 ^ (((long) bArr[i7]) << 49);
                                        if (j10 < 0) {
                                            j5 = -558586000294016L;
                                        } else {
                                            i7 = i4 + 9;
                                            long j11 = (j10 ^ (((long) bArr[i11]) << 56)) ^ 71499008037633920L;
                                            if (j11 < 0) {
                                                int i13 = i4 + 10;
                                                if (bArr[i7] >= 0) {
                                                    i7 = i13;
                                                }
                                            }
                                            j4 = j11;
                                        }
                                    }
                                }
                                j7 = j5 ^ j10;
                            }
                            j4 = j6 ^ j9;
                        }
                        i7 = i11;
                        j4 = j7;
                    }
                }
                this.f3805g = i7;
                return j4;
            }
        }
        return O();
    }

    public final long O() throws B {
        long j4 = 0;
        for (int i4 = 0; i4 < 64; i4 += 7) {
            if (this.f3805g == this.e) {
                Q(1);
            }
            int i5 = this.f3805g;
            this.f3805g = i5 + 1;
            byte b5 = this.f3803d[i5];
            j4 |= ((long) (b5 & 127)) << i4;
            if ((b5 & 128) == 0) {
                return j4;
            }
        }
        throw B.d();
    }

    public final void P() {
        int i4 = this.e + this.f3804f;
        this.e = i4;
        int i5 = this.f3807i + i4;
        int i6 = this.f3808j;
        if (i5 <= i6) {
            this.f3804f = 0;
            return;
        }
        int i7 = i5 - i6;
        this.f3804f = i7;
        this.e = i4 - i7;
    }

    public final void Q(int i4) throws B {
        if (S(i4)) {
            return;
        }
        if (i4 <= (com.google.android.gms.common.api.f.API_PRIORITY_OTHER - this.f3807i) - this.f3805g) {
            throw B.g();
        }
        throw new B("Protocol message was too large.  May be malicious.  Use CodedInputStream.setSizeLimit() to increase the size limit.");
    }

    public final void R(int i4) throws B {
        int i5 = this.e;
        int i6 = this.f3805g;
        int i7 = i5 - i6;
        if (i4 <= i7 && i4 >= 0) {
            this.f3805g = i6 + i4;
            return;
        }
        ByteArrayInputStream byteArrayInputStream = this.f3802c;
        if (i4 < 0) {
            throw B.e();
        }
        int i8 = this.f3807i;
        int i9 = i8 + i6;
        int i10 = i9 + i4;
        int i11 = this.f3808j;
        if (i10 > i11) {
            R((i11 - i8) - i6);
            throw B.g();
        }
        this.f3807i = i9;
        this.e = 0;
        this.f3805g = 0;
        while (i7 < i4) {
            long j4 = i4 - i7;
            try {
                try {
                    long jSkip = byteArrayInputStream.skip(j4);
                    if (jSkip < 0 || jSkip > j4) {
                        throw new IllegalStateException(byteArrayInputStream.getClass() + "#skip returned invalid result: " + jSkip + "\nThe InputStream implementation is buggy.");
                    }
                    if (jSkip == 0) {
                        break;
                    } else {
                        i7 += (int) jSkip;
                    }
                } catch (B e) {
                    e.f3723a = true;
                    throw e;
                }
            } catch (Throwable th) {
                this.f3807i += i7;
                P();
                throw th;
            }
        }
        this.f3807i += i7;
        P();
        if (i7 >= i4) {
            return;
        }
        int i12 = this.e;
        int i13 = i12 - this.f3805g;
        this.f3805g = i12;
        Q(1);
        while (true) {
            int i14 = i4 - i13;
            int i15 = this.e;
            if (i14 <= i15) {
                this.f3805g = i14;
                return;
            } else {
                i13 += i15;
                this.f3805g = i15;
                Q(1);
            }
        }
    }

    public final boolean S(int i4) throws IOException {
        int i5 = this.f3805g;
        int i6 = i5 + i4;
        int i7 = this.e;
        if (i6 <= i7) {
            throw new IllegalStateException(B1.a.l("refillBuffer() called when ", i4, " bytes were already available in buffer"));
        }
        int i8 = this.f3807i;
        if (i4 <= (com.google.android.gms.common.api.f.API_PRIORITY_OTHER - i8) - i5 && i8 + i5 + i4 <= this.f3808j) {
            byte[] bArr = this.f3803d;
            if (i5 > 0) {
                if (i7 > i5) {
                    System.arraycopy(bArr, i5, bArr, 0, i7 - i5);
                }
                this.f3807i += i5;
                this.e -= i5;
                this.f3805g = 0;
            }
            int i9 = this.e;
            int iMin = Math.min(bArr.length - i9, (com.google.android.gms.common.api.f.API_PRIORITY_OTHER - this.f3807i) - i9);
            ByteArrayInputStream byteArrayInputStream = this.f3802c;
            try {
                int i10 = byteArrayInputStream.read(bArr, i9, iMin);
                if (i10 == 0 || i10 < -1 || i10 > bArr.length) {
                    throw new IllegalStateException(byteArrayInputStream.getClass() + "#read(byte[]) returned invalid result: " + i10 + "\nThe InputStream implementation is buggy.");
                }
                if (i10 > 0) {
                    this.e += i10;
                    P();
                    if (this.e >= i4) {
                        return true;
                    }
                    return S(i4);
                }
            } catch (B e) {
                e.f3723a = true;
                throw e;
            }
        }
        return false;
    }

    @Override // T0.d
    public final void b(int i4) throws B {
        if (this.f3806h != i4) {
            throw new B("Protocol message end-group tag did not match expected tag.");
        }
    }

    @Override // T0.d
    public final int f() {
        return this.f3807i + this.f3805g;
    }

    @Override // T0.d
    public final boolean g() {
        return this.f3805g == this.e && !S(1);
    }

    @Override // T0.d
    public final void j(int i4) {
        this.f3808j = i4;
        P();
    }

    @Override // T0.d
    public final int l(int i4) throws B {
        if (i4 < 0) {
            throw B.e();
        }
        int i5 = this.f3807i + this.f3805g + i4;
        int i6 = this.f3808j;
        if (i5 > i6) {
            throw B.g();
        }
        this.f3808j = i5;
        P();
        return i6;
    }

    @Override // T0.d
    public final boolean m() {
        return N() != 0;
    }

    @Override // T0.d
    public final C0302g o() throws IOException {
        int iM = M();
        int i4 = this.e;
        int i5 = this.f3805g;
        int i6 = i4 - i5;
        byte[] bArr = this.f3803d;
        if (iM <= i6 && iM > 0) {
            C0302g c0302gH = AbstractC0303h.h(bArr, i5, iM);
            this.f3805g += iM;
            return c0302gH;
        }
        if (iM == 0) {
            return AbstractC0303h.f3791b;
        }
        byte[] bArrI = I(iM);
        if (bArrI != null) {
            return AbstractC0303h.h(bArrI, 0, bArrI.length);
        }
        int i7 = this.f3805g;
        int i8 = this.e;
        int length = i8 - i7;
        this.f3807i += i8;
        this.f3805g = 0;
        this.e = 0;
        ArrayList<byte[]> arrayListJ = J(iM - length);
        byte[] bArr2 = new byte[iM];
        System.arraycopy(bArr, i7, bArr2, 0, length);
        for (byte[] bArr3 : arrayListJ) {
            System.arraycopy(bArr3, 0, bArr2, length, bArr3.length);
            length += bArr3.length;
        }
        C0302g c0302g = AbstractC0303h.f3791b;
        return new C0302g(bArr2);
    }

    @Override // T0.d
    public final double p() {
        return Double.longBitsToDouble(L());
    }

    @Override // T0.d
    public final int q() {
        return M();
    }

    @Override // T0.d
    public final int r() {
        return K();
    }

    @Override // T0.d
    public final long s() {
        return L();
    }

    @Override // T0.d
    public final float t() {
        return Float.intBitsToFloat(K());
    }

    @Override // T0.d
    public final int u() {
        return M();
    }

    @Override // T0.d
    public final long v() {
        return N();
    }

    @Override // T0.d
    public final int w() {
        return K();
    }

    @Override // T0.d
    public final long x() {
        return L();
    }

    @Override // T0.d
    public final int y() {
        return T0.d.d(M());
    }

    @Override // T0.d
    public final long z() {
        return T0.d.e(N());
    }
}
