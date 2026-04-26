package x3;

import java.util.RandomAccess;

/* JADX INFO: renamed from: x3.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0727g extends AbstractC0723c implements RandomAccess {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ byte[] f6782a;

    public C0727g(byte[] bArr) {
        this.f6782a = bArr;
    }

    @Override // x3.AbstractC0723c, java.util.List, java.util.Collection
    public final boolean contains(Object obj) {
        if (!(obj instanceof Byte)) {
            return false;
        }
        byte bByteValue = ((Number) obj).byteValue();
        byte[] bArr = this.f6782a;
        int length = bArr.length;
        int i4 = 0;
        while (true) {
            if (i4 >= length) {
                i4 = -1;
                break;
            }
            if (bByteValue == bArr[i4]) {
                break;
            }
            i4++;
        }
        return i4 >= 0;
    }

    @Override // x3.AbstractC0723c
    public final int f() {
        return this.f6782a.length;
    }

    @Override // java.util.List
    public final Object get(int i4) {
        return Byte.valueOf(this.f6782a[i4]);
    }

    @Override // x3.AbstractC0723c, java.util.List
    public final int indexOf(Object obj) {
        if (!(obj instanceof Byte)) {
            return -1;
        }
        byte bByteValue = ((Number) obj).byteValue();
        byte[] bArr = this.f6782a;
        int length = bArr.length;
        for (int i4 = 0; i4 < length; i4++) {
            if (bByteValue == bArr[i4]) {
                return i4;
            }
        }
        return -1;
    }

    @Override // x3.AbstractC0723c, java.util.List, java.util.Collection
    public final boolean isEmpty() {
        return this.f6782a.length == 0;
    }

    @Override // x3.AbstractC0723c, java.util.List
    public final int lastIndexOf(Object obj) {
        if (!(obj instanceof Byte)) {
            return -1;
        }
        byte bByteValue = ((Number) obj).byteValue();
        byte[] bArr = this.f6782a;
        J3.i.e(bArr, "<this>");
        int length = bArr.length - 1;
        if (length >= 0) {
            while (true) {
                int i4 = length - 1;
                if (bByteValue == bArr[length]) {
                    return length;
                }
                if (i4 < 0) {
                    break;
                }
                length = i4;
            }
        }
        return -1;
    }
}
