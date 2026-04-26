package G3;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final byte[] f503a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final byte[] f504b;

    static {
        byte[] bArr = {65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47};
        f503a = bArr;
        int[] iArr = new int[256];
        int i4 = 0;
        Arrays.fill(iArr, 0, 256, -1);
        iArr[61] = -2;
        int i5 = 0;
        int i6 = 0;
        while (i5 < 64) {
            iArr[bArr[i5]] = i6;
            i5++;
            i6++;
        }
        byte[] bArr2 = {65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 45, 95};
        f504b = bArr2;
        int[] iArr2 = new int[256];
        Arrays.fill(iArr2, 0, 256, -1);
        iArr2[61] = -2;
        int i7 = 0;
        while (i4 < 64) {
            iArr2[bArr2[i4]] = i7;
            i4++;
            i7++;
        }
    }
}
