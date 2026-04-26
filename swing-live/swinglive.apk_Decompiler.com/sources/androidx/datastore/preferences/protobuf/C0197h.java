package androidx.datastore.preferences.protobuf;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0197h extends T0.d {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f2973c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2974d;
    public int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f2975f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f2976g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public int f2977h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public int f2978i = com.google.android.gms.common.api.f.API_PRIORITY_OTHER;

    public C0197h(byte[] bArr, int i4, int i5, boolean z4) {
        this.f2973c = bArr;
        this.f2974d = i5 + i4;
        this.f2975f = i4;
        this.f2976g = i4;
    }

    @Override // T0.d
    public final String A() throws C0213y {
        int iJ = J();
        if (iJ > 0) {
            int i4 = this.f2974d;
            int i5 = this.f2975f;
            if (iJ <= i4 - i5) {
                String str = new String(this.f2973c, i5, iJ, AbstractC0211w.f3035a);
                this.f2975f += iJ;
                return str;
            }
        }
        if (iJ == 0) {
            return "";
        }
        if (iJ < 0) {
            throw C0213y.d();
        }
        throw C0213y.e();
    }

    @Override // T0.d
    public final String B() throws C0213y {
        int iJ = J();
        if (iJ > 0) {
            int i4 = this.f2974d;
            int i5 = this.f2975f;
            if (iJ <= i4 - i5) {
                String strV = k0.f3004a.v(this.f2973c, i5, iJ);
                this.f2975f += iJ;
                return strV;
            }
        }
        if (iJ == 0) {
            return "";
        }
        if (iJ <= 0) {
            throw C0213y.d();
        }
        throw C0213y.e();
    }

    @Override // T0.d
    public final int C() throws C0213y {
        if (g()) {
            this.f2977h = 0;
            return 0;
        }
        int iJ = J();
        this.f2977h = iJ;
        if ((iJ >>> 3) != 0) {
            return iJ;
        }
        throw new C0213y("Protocol message contained an invalid tag (zero).");
    }

    @Override // T0.d
    public final int D() {
        return J();
    }

    @Override // T0.d
    public final long E() {
        return K();
    }

    @Override // T0.d
    public final boolean F(int i4) throws C0213y {
        int i5 = i4 & 7;
        int i6 = 0;
        if (i5 != 0) {
            if (i5 == 1) {
                N(8);
                return true;
            }
            if (i5 == 2) {
                N(J());
                return true;
            }
            if (i5 == 3) {
                G();
                b(((i4 >>> 3) << 3) | 4);
                return true;
            }
            if (i5 == 4) {
                return false;
            }
            if (i5 != 5) {
                throw C0213y.b();
            }
            N(4);
            return true;
        }
        int i7 = this.f2974d - this.f2975f;
        byte[] bArr = this.f2973c;
        if (i7 >= 10) {
            while (i6 < 10) {
                int i8 = this.f2975f;
                this.f2975f = i8 + 1;
                if (bArr[i8] < 0) {
                    i6++;
                }
            }
            throw C0213y.c();
        }
        while (i6 < 10) {
            int i9 = this.f2975f;
            if (i9 == this.f2974d) {
                throw C0213y.e();
            }
            this.f2975f = i9 + 1;
            if (bArr[i9] < 0) {
                i6++;
            }
        }
        throw C0213y.c();
        return true;
    }

    public final int H() throws C0213y {
        int i4 = this.f2975f;
        if (this.f2974d - i4 < 4) {
            throw C0213y.e();
        }
        this.f2975f = i4 + 4;
        byte[] bArr = this.f2973c;
        return ((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16);
    }

    public final long I() throws C0213y {
        int i4 = this.f2975f;
        if (this.f2974d - i4 < 8) {
            throw C0213y.e();
        }
        this.f2975f = i4 + 8;
        byte[] bArr = this.f2973c;
        return ((((long) bArr[i4 + 7]) & 255) << 56) | (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48);
    }

    public final int J() {
        int i4;
        int i5 = this.f2975f;
        int i6 = this.f2974d;
        if (i6 != i5) {
            int i7 = i5 + 1;
            byte[] bArr = this.f2973c;
            byte b5 = bArr[i5];
            if (b5 >= 0) {
                this.f2975f = i7;
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
                this.f2975f = i8;
                return i4;
            }
        }
        return (int) L();
    }

    public final long K() {
        long j4;
        long j5;
        long j6;
        long j7;
        int i4 = this.f2975f;
        int i5 = this.f2974d;
        if (i5 != i4) {
            int i6 = i4 + 1;
            byte[] bArr = this.f2973c;
            byte b5 = bArr[i4];
            if (b5 >= 0) {
                this.f2975f = i6;
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
                this.f2975f = i7;
                return j4;
            }
        }
        return L();
    }

    public final long L() throws C0213y {
        long j4 = 0;
        for (int i4 = 0; i4 < 64; i4 += 7) {
            int i5 = this.f2975f;
            if (i5 == this.f2974d) {
                throw C0213y.e();
            }
            this.f2975f = i5 + 1;
            byte b5 = this.f2973c[i5];
            j4 |= ((long) (b5 & 127)) << i4;
            if ((b5 & 128) == 0) {
                return j4;
            }
        }
        throw C0213y.c();
    }

    public final void M() {
        int i4 = this.f2974d + this.e;
        this.f2974d = i4;
        int i5 = i4 - this.f2976g;
        int i6 = this.f2978i;
        if (i5 <= i6) {
            this.e = 0;
            return;
        }
        int i7 = i5 - i6;
        this.e = i7;
        this.f2974d = i4 - i7;
    }

    public final void N(int i4) throws C0213y {
        if (i4 >= 0) {
            int i5 = this.f2974d;
            int i6 = this.f2975f;
            if (i4 <= i5 - i6) {
                this.f2975f = i6 + i4;
                return;
            }
        }
        if (i4 >= 0) {
            throw C0213y.e();
        }
        throw C0213y.d();
    }

    @Override // T0.d
    public final void b(int i4) throws C0213y {
        if (this.f2977h != i4) {
            throw new C0213y("Protocol message end-group tag did not match expected tag.");
        }
    }

    @Override // T0.d
    public final int f() {
        return this.f2975f - this.f2976g;
    }

    @Override // T0.d
    public final boolean g() {
        return this.f2975f == this.f2974d;
    }

    @Override // T0.d
    public final void j(int i4) {
        this.f2978i = i4;
        M();
    }

    @Override // T0.d
    public final int l(int i4) throws C0213y {
        if (i4 < 0) {
            throw C0213y.d();
        }
        int iF = f() + i4;
        if (iF < 0) {
            throw new C0213y("Failed to parse the message.");
        }
        int i5 = this.f2978i;
        if (iF > i5) {
            throw C0213y.e();
        }
        this.f2978i = iF;
        M();
        return i5;
    }

    @Override // T0.d
    public final boolean m() {
        return K() != 0;
    }

    /* JADX WARN: Removed duplicated region for block: B:15:0x002f  */
    @Override // T0.d
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final androidx.datastore.preferences.protobuf.C0196g n() throws androidx.datastore.preferences.protobuf.C0213y {
        /*
            r4 = this;
            int r0 = r4.J()
            byte[] r1 = r4.f2973c
            if (r0 <= 0) goto L19
            int r2 = r4.f2974d
            int r3 = r4.f2975f
            int r2 = r2 - r3
            if (r0 > r2) goto L19
            androidx.datastore.preferences.protobuf.g r1 = androidx.datastore.preferences.protobuf.C0196g.h(r1, r3, r0)
            int r2 = r4.f2975f
            int r2 = r2 + r0
            r4.f2975f = r2
            return r1
        L19:
            if (r0 != 0) goto L1e
            androidx.datastore.preferences.protobuf.g r0 = androidx.datastore.preferences.protobuf.C0196g.f2968c
            return r0
        L1e:
            if (r0 <= 0) goto L2f
            int r2 = r4.f2974d
            int r3 = r4.f2975f
            int r2 = r2 - r3
            if (r0 > r2) goto L2f
            int r0 = r0 + r3
            r4.f2975f = r0
            byte[] r0 = java.util.Arrays.copyOfRange(r1, r3, r0)
            goto L35
        L2f:
            if (r0 > 0) goto L42
            if (r0 != 0) goto L3d
            byte[] r0 = androidx.datastore.preferences.protobuf.AbstractC0211w.f3036b
        L35:
            androidx.datastore.preferences.protobuf.g r1 = androidx.datastore.preferences.protobuf.C0196g.f2968c
            androidx.datastore.preferences.protobuf.g r1 = new androidx.datastore.preferences.protobuf.g
            r1.<init>(r0)
            return r1
        L3d:
            androidx.datastore.preferences.protobuf.y r0 = androidx.datastore.preferences.protobuf.C0213y.d()
            throw r0
        L42:
            androidx.datastore.preferences.protobuf.y r0 = androidx.datastore.preferences.protobuf.C0213y.e()
            throw r0
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.datastore.preferences.protobuf.C0197h.n():androidx.datastore.preferences.protobuf.g");
    }

    @Override // T0.d
    public final double p() {
        return Double.longBitsToDouble(I());
    }

    @Override // T0.d
    public final int q() {
        return J();
    }

    @Override // T0.d
    public final int r() {
        return H();
    }

    @Override // T0.d
    public final long s() {
        return I();
    }

    @Override // T0.d
    public final float t() {
        return Float.intBitsToFloat(H());
    }

    @Override // T0.d
    public final int u() {
        return J();
    }

    @Override // T0.d
    public final long v() {
        return K();
    }

    @Override // T0.d
    public final int w() {
        return H();
    }

    @Override // T0.d
    public final long x() {
        return I();
    }

    @Override // T0.d
    public final int y() {
        int iJ = J();
        return (-(iJ & 1)) ^ (iJ >>> 1);
    }

    @Override // T0.d
    public final long z() {
        long jK = K();
        return (-(jK & 1)) ^ (jK >>> 1);
    }
}
