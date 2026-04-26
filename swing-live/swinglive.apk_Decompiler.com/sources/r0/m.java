package R0;

import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class m implements Comparable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f1702a;

    public m(byte[] bArr) {
        this.f1702a = Arrays.copyOf(bArr, bArr.length);
    }

    @Override // java.lang.Comparable
    public final int compareTo(Object obj) {
        m mVar = (m) obj;
        byte[] bArr = this.f1702a;
        int length = bArr.length;
        byte[] bArr2 = mVar.f1702a;
        if (length != bArr2.length) {
            return bArr.length - bArr2.length;
        }
        for (int i4 = 0; i4 < bArr.length; i4++) {
            byte b5 = bArr[i4];
            byte b6 = mVar.f1702a[i4];
            if (b5 != b6) {
                return b5 - b6;
            }
        }
        return 0;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof m) {
            return Arrays.equals(this.f1702a, ((m) obj).f1702a);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(this.f1702a);
    }

    public final String toString() {
        return e1.k.p(this.f1702a);
    }
}
