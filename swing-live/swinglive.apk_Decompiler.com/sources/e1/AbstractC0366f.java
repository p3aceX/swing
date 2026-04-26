package e1;

import java.nio.charset.Charset;

/* JADX INFO: renamed from: e1.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0366f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Charset f3992a = Charset.forName("UTF-8");

    /* JADX WARN: Code restructure failed: missing block: B:54:0x00e2, code lost:
    
        if (r7 != 4) goto L58;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static byte[] a(java.lang.String r15) {
        /*
            Method dump skipped, instruction units count: 269
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: e1.AbstractC0366f.a(java.lang.String):byte[]");
    }

    public static byte[] b(byte[] bArr) {
        int length = bArr.length;
        byte[] bArr2 = AbstractC0365e.f3991c;
        int i4 = (length / 3) * 4;
        if (length % 3 > 0) {
            i4 += 4;
        }
        byte[] bArr3 = new byte[i4];
        int i5 = 0;
        int i6 = -1;
        int i7 = 0;
        while (true) {
            int i8 = i5 + 3;
            if (i8 > length) {
                break;
            }
            int i9 = (bArr[i5 + 2] & 255) | ((bArr[i5] & 255) << 16) | ((bArr[i5 + 1] & 255) << 8);
            bArr3[i7] = bArr2[(i9 >> 18) & 63];
            bArr3[i7 + 1] = bArr2[(i9 >> 12) & 63];
            bArr3[i7 + 2] = bArr2[(i9 >> 6) & 63];
            bArr3[i7 + 3] = bArr2[i9 & 63];
            int i10 = i7 + 4;
            i6--;
            if (i6 == 0) {
                i7 += 5;
                bArr3[i10] = 10;
                i6 = 19;
            } else {
                i7 = i10;
            }
            i5 = i8;
        }
        if (i5 == length - 1) {
            int i11 = (bArr[i5] & 255) << 4;
            bArr3[i7] = bArr2[(i11 >> 6) & 63];
            bArr3[i7 + 1] = bArr2[i11 & 63];
            bArr3[i7 + 2] = 61;
            bArr3[i7 + 3] = 61;
            return bArr3;
        }
        if (i5 == length - 2) {
            int i12 = ((bArr[i5 + 1] & 255) << 2) | ((bArr[i5] & 255) << 10);
            bArr3[i7] = bArr2[(i12 >> 12) & 63];
            bArr3[i7 + 1] = bArr2[(i12 >> 6) & 63];
            bArr3[i7 + 2] = bArr2[i12 & 63];
            bArr3[i7 + 3] = 61;
        }
        return bArr3;
    }
}
