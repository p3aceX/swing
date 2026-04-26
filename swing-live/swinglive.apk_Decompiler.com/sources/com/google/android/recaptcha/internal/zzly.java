package com.google.android.recaptcha.internal;

/* JADX INFO: loaded from: classes.dex */
final class zzly extends zzlx {
    @Override // com.google.android.recaptcha.internal.zzlx
    public final int zza(int i4, byte[] bArr, int i5, int i6) {
        while (i5 < i6 && bArr[i5] >= 0) {
            i5++;
        }
        if (i5 >= i6) {
            return 0;
        }
        while (i5 < i6) {
            int i7 = i5 + 1;
            byte b5 = bArr[i5];
            if (b5 >= 0) {
                i5 = i7;
            } else {
                if (b5 < -32) {
                    if (i7 >= i6) {
                        return b5;
                    }
                    if (b5 >= -62) {
                        i5 += 2;
                        if (bArr[i7] > -65) {
                        }
                    }
                    return -1;
                }
                if (b5 >= -16) {
                    if (i7 >= i6 - 2) {
                        return zzma.zza(bArr, i7, i6);
                    }
                    int i8 = i5 + 2;
                    byte b6 = bArr[i7];
                    if (b6 <= -65) {
                        if ((((b6 + 112) + (b5 << 28)) >> 30) == 0) {
                            int i9 = i5 + 3;
                            if (bArr[i8] <= -65) {
                                i5 += 4;
                                if (bArr[i9] > -65) {
                                }
                            }
                        }
                    }
                    return -1;
                }
                if (i7 >= i6 - 1) {
                    return zzma.zza(bArr, i7, i6);
                }
                int i10 = i5 + 2;
                byte b7 = bArr[i7];
                if (b7 > -65 || (b5 == -32 && b7 < -96)) {
                    return -1;
                }
                if (b5 == -19 && b7 >= -96) {
                    return -1;
                }
                i5 += 3;
                if (bArr[i10] > -65) {
                    return -1;
                }
            }
        }
        return 0;
    }
}
