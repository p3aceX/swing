package f1;

import e1.k;
import java.util.Arrays;

/* JADX INFO: renamed from: f1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0400a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f4284a;

    public C0400a(byte[] bArr, int i4) {
        byte[] bArr2 = new byte[i4];
        this.f4284a = bArr2;
        System.arraycopy(bArr, 0, bArr2, 0, i4);
    }

    public static C0400a a(byte[] bArr) {
        if (bArr != null) {
            return new C0400a(bArr, bArr.length);
        }
        throw new NullPointerException("data must be non-null");
    }

    public final boolean equals(Object obj) {
        if (obj instanceof C0400a) {
            return Arrays.equals(((C0400a) obj).f4284a, this.f4284a);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(this.f4284a);
    }

    public final String toString() {
        return "Bytes(" + k.p(this.f4284a) + ")";
    }
}
