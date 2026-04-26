package G3;

import com.google.android.gms.common.api.f;
import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public class c {
    public static final a e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final byte[] f498f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f499a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f500b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f501c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f502d;

    static {
        b[] bVarArr = b.f497a;
        e = new a(-1, false, false);
        f498f = new byte[]{13, 10};
        new c(-1, true, false);
        new c(76, false, true);
        new c(64, false, true);
    }

    public c(int i4, boolean z4, boolean z5) {
        b[] bVarArr = b.f497a;
        this.f499a = z4;
        this.f500b = z5;
        this.f501c = i4;
        if (z4 && z5) {
            throw new IllegalArgumentException("Failed requirement.");
        }
        this.f502d = i4 / 4;
    }

    public static void a(int i4, int i5) {
        if (i5 > i4) {
            throw new IndexOutOfBoundsException(B1.a.k("startIndex: 0, endIndex: ", i5, i4, ", size: "));
        }
        if (i5 < 0) {
            throw new IllegalArgumentException(S.d(i5, "startIndex: 0 > endIndex: "));
        }
    }

    public static String b(a aVar, byte[] bArr) {
        int i4;
        int length = bArr.length;
        aVar.getClass();
        a(bArr.length, length);
        int iC = aVar.c(length);
        byte[] bArr2 = new byte[iC];
        a(bArr.length, length);
        int iC2 = aVar.c(length);
        if (iC < 0) {
            throw new IndexOutOfBoundsException(S.d(iC, "destination offset: 0, destination size: "));
        }
        if (iC2 < 0 || iC2 > iC) {
            throw new IndexOutOfBoundsException(B1.a.k("The destination array does not have enough capacity, destination offset: 0, destination size: ", iC, iC2, ", capacity needed: "));
        }
        byte[] bArr3 = aVar.f499a ? d.f504b : d.f503a;
        int i5 = aVar.f500b ? aVar.f502d : f.API_PRIORITY_OTHER;
        int i6 = 0;
        int i7 = 0;
        while (true) {
            i4 = i6 + 2;
            if (i4 >= length) {
                break;
            }
            int iMin = Math.min((length - i6) / 3, i5);
            for (int i8 = 0; i8 < iMin; i8++) {
                int i9 = bArr[i6] & 255;
                int i10 = i6 + 2;
                int i11 = bArr[i6 + 1] & 255;
                i6 += 3;
                int i12 = (i11 << 8) | (i9 << 16) | (bArr[i10] & 255);
                bArr2[i7] = bArr3[i12 >>> 18];
                bArr2[i7 + 1] = bArr3[(i12 >>> 12) & 63];
                int i13 = i7 + 3;
                bArr2[i7 + 2] = bArr3[(i12 >>> 6) & 63];
                i7 += 4;
                bArr2[i13] = bArr3[i12 & 63];
            }
            if (iMin == i5 && i6 != length) {
                int i14 = i7 + 1;
                byte[] bArr4 = f498f;
                bArr2[i7] = bArr4[0];
                i7 += 2;
                bArr2[i14] = bArr4[1];
            }
        }
        int i15 = length - i6;
        if (i15 == 1) {
            int i16 = (bArr[i6] & 255) << 4;
            bArr2[i7] = bArr3[i16 >>> 6];
            bArr2[1 + i7] = bArr3[i16 & 63];
            b[] bVarArr = b.f497a;
            bArr2[2 + i7] = 61;
            bArr2[i7 + 3] = 61;
            i6++;
        } else if (i15 == 2) {
            int i17 = ((bArr[i6 + 1] & 255) << 2) | ((bArr[i6] & 255) << 10);
            bArr2[i7] = bArr3[i17 >>> 12];
            bArr2[1 + i7] = bArr3[(i17 >>> 6) & 63];
            bArr2[2 + i7] = bArr3[i17 & 63];
            b[] bVarArr2 = b.f497a;
            bArr2[i7 + 3] = 61;
            i6 = i4;
        }
        if (i6 == length) {
            return new String(bArr2, P3.a.f1493b);
        }
        throw new IllegalStateException("Check failed.");
    }

    public final int c(int i4) {
        int i5 = (i4 / 3) * 4;
        if (i4 % 3 != 0) {
            b[] bVarArr = b.f497a;
            i5 += 4;
        }
        if (i5 < 0) {
            throw new IllegalArgumentException("Input is too big");
        }
        if (this.f500b) {
            i5 += ((i5 - 1) / this.f501c) * 2;
        }
        if (i5 >= 0) {
            return i5;
        }
        throw new IllegalArgumentException("Input is too big");
    }
}
