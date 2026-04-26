package com.google.crypto.tink.shaded.protobuf;

import a.AbstractC0184a;

/* JADX INFO: loaded from: classes.dex */
public final class p0 extends AbstractC0184a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f3829b;

    public /* synthetic */ p0(int i4) {
        this.f3829b = i4;
    }

    public static int p0(long j4, byte[] bArr, int i4, int i5) {
        if (i5 == 0) {
            AbstractC0184a abstractC0184a = r0.f3834a;
            if (i4 > -12) {
                return -1;
            }
            return i4;
        }
        if (i5 == 1) {
            return r0.c(i4, o0.g(bArr, j4));
        }
        if (i5 == 2) {
            return r0.d(i4, o0.g(bArr, j4), o0.g(bArr, j4 + 1));
        }
        throw new AssertionError();
    }

    @Override // a.AbstractC0184a
    public final int C(String str, byte[] bArr, int i4, int i5) {
        int i6;
        int i7;
        char cCharAt;
        long j4;
        char c5;
        long j5;
        long j6;
        char c6;
        int i8;
        char cCharAt2;
        switch (this.f3829b) {
            case 0:
                int length = str.length();
                int i9 = i5 + i4;
                int i10 = 0;
                while (i10 < length && (i7 = i10 + i4) < i9 && (cCharAt = str.charAt(i10)) < 128) {
                    bArr[i7] = (byte) cCharAt;
                    i10++;
                }
                if (i10 == length) {
                    return i4 + length;
                }
                int i11 = i4 + i10;
                while (i10 < length) {
                    char cCharAt3 = str.charAt(i10);
                    if (cCharAt3 < 128 && i11 < i9) {
                        bArr[i11] = (byte) cCharAt3;
                        i11++;
                    } else if (cCharAt3 < 2048 && i11 <= i9 - 2) {
                        int i12 = i11 + 1;
                        bArr[i11] = (byte) ((cCharAt3 >>> 6) | 960);
                        i11 += 2;
                        bArr[i12] = (byte) ((cCharAt3 & '?') | 128);
                    } else {
                        if ((cCharAt3 >= 55296 && 57343 >= cCharAt3) || i11 > i9 - 3) {
                            if (i11 > i9 - 4) {
                                if (55296 <= cCharAt3 && cCharAt3 <= 57343 && ((i6 = i10 + 1) == str.length() || !Character.isSurrogatePair(cCharAt3, str.charAt(i6)))) {
                                    throw new q0(i10, length);
                                }
                                throw new ArrayIndexOutOfBoundsException("Failed writing " + cCharAt3 + " at index " + i11);
                            }
                            int i13 = i10 + 1;
                            if (i13 != str.length()) {
                                char cCharAt4 = str.charAt(i13);
                                if (Character.isSurrogatePair(cCharAt3, cCharAt4)) {
                                    int codePoint = Character.toCodePoint(cCharAt3, cCharAt4);
                                    bArr[i11] = (byte) ((codePoint >>> 18) | 240);
                                    bArr[i11 + 1] = (byte) (((codePoint >>> 12) & 63) | 128);
                                    int i14 = i11 + 3;
                                    bArr[i11 + 2] = (byte) (((codePoint >>> 6) & 63) | 128);
                                    i11 += 4;
                                    bArr[i14] = (byte) ((codePoint & 63) | 128);
                                    i10 = i13;
                                } else {
                                    i10 = i13;
                                }
                            }
                            throw new q0(i10 - 1, length);
                        }
                        bArr[i11] = (byte) ((cCharAt3 >>> '\f') | 480);
                        int i15 = i11 + 2;
                        bArr[i11 + 1] = (byte) (((cCharAt3 >>> 6) & 63) | 128);
                        i11 += 3;
                        bArr[i15] = (byte) ((cCharAt3 & '?') | 128);
                    }
                    i10++;
                }
                return i11;
            default:
                long j7 = i4;
                long j8 = ((long) i5) + j7;
                int length2 = str.length();
                if (length2 > i5 || bArr.length - i5 < i4) {
                    throw new ArrayIndexOutOfBoundsException("Failed writing " + str.charAt(length2 - 1) + " at index " + (i4 + i5));
                }
                int i16 = 0;
                while (true) {
                    j4 = 1;
                    c5 = 128;
                    if (i16 < length2 && (cCharAt2 = str.charAt(i16)) < 128) {
                        o0.k(bArr, j7, (byte) cCharAt2);
                        i16++;
                        j7 = 1 + j7;
                    }
                }
                if (i16 == length2) {
                    return (int) j7;
                }
                while (i16 < length2) {
                    char cCharAt5 = str.charAt(i16);
                    if (cCharAt5 < c5 && j7 < j8) {
                        o0.k(bArr, j7, (byte) cCharAt5);
                        c6 = c5;
                        j5 = j4;
                        j6 = j7 + j4;
                    } else if (cCharAt5 >= 2048 || j7 > j8 - 2) {
                        j5 = j4;
                        if ((cCharAt5 >= 55296 && 57343 >= cCharAt5) || j7 > j8 - 3) {
                            long j9 = j7;
                            if (j9 > j8 - 4) {
                                if (55296 <= cCharAt5 && cCharAt5 <= 57343 && ((i8 = i16 + 1) == length2 || !Character.isSurrogatePair(cCharAt5, str.charAt(i8)))) {
                                    throw new q0(i16, length2);
                                }
                                throw new ArrayIndexOutOfBoundsException("Failed writing " + cCharAt5 + " at index " + j9);
                            }
                            int i17 = i16 + 1;
                            if (i17 != length2) {
                                char cCharAt6 = str.charAt(i17);
                                if (Character.isSurrogatePair(cCharAt5, cCharAt6)) {
                                    int codePoint2 = Character.toCodePoint(cCharAt5, cCharAt6);
                                    o0.k(bArr, j9, (byte) ((codePoint2 >>> 18) | 240));
                                    c6 = 128;
                                    o0.k(bArr, j9 + j5, (byte) (((codePoint2 >>> 12) & 63) | 128));
                                    o0.k(bArr, j9 + 2, (byte) (((codePoint2 >>> 6) & 63) | 128));
                                    o0.k(bArr, j9 + 3, (byte) ((codePoint2 & 63) | 128));
                                    j6 = j9 + 4;
                                    i16 = i17;
                                } else {
                                    i16 = i17;
                                }
                            }
                            throw new q0(i16 - 1, length2);
                        }
                        o0.k(bArr, j7, (byte) ((cCharAt5 >>> '\f') | 480));
                        long j10 = j7;
                        o0.k(bArr, j7 + j5, (byte) (((cCharAt5 >>> 6) & 63) | 128));
                        j6 = j10 + 3;
                        o0.k(bArr, j10 + 2, (byte) ((cCharAt5 & '?') | 128));
                        c6 = 128;
                    } else {
                        j5 = j4;
                        o0.k(bArr, j7, (byte) ((cCharAt5 >>> 6) | 960));
                        o0.k(bArr, j7 + j5, (byte) ((cCharAt5 & '?') | c5));
                        j6 = j7 + 2;
                        c6 = c5;
                    }
                    i16++;
                    c5 = c6;
                    j7 = j6;
                    j4 = j5;
                }
                return (int) j7;
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:75:0x00fa, code lost:
    
        return -1;
     */
    @Override // a.AbstractC0184a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final int T(byte[] r18, int r19, int r20) {
        /*
            Method dump skipped, instruction units count: 410
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.crypto.tink.shaded.protobuf.p0.T(byte[], int, int):int");
    }

    /* JADX WARN: Removed duplicated region for block: B:20:0x0049  */
    @Override // a.AbstractC0184a
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.String v(byte[] r11, int r12, int r13) throws com.google.crypto.tink.shaded.protobuf.B {
        /*
            Method dump skipped, instruction units count: 352
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.crypto.tink.shaded.protobuf.p0.v(byte[], int, int):java.lang.String");
    }
}
