package com.google.crypto.tink.shaded.protobuf;

import androidx.datastore.preferences.protobuf.C0193d;
import java.util.Iterator;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0302g extends AbstractC0303h {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final byte[] f3790d;

    public C0302g(byte[] bArr) {
        this.f3793a = 0;
        bArr.getClass();
        this.f3790d = bArr;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof AbstractC0303h) || size() != ((AbstractC0303h) obj).size()) {
            return false;
        }
        if (size() == 0) {
            return true;
        }
        if (!(obj instanceof C0302g)) {
            return obj.equals(this);
        }
        C0302g c0302g = (C0302g) obj;
        int i4 = this.f3793a;
        int i5 = c0302g.f3793a;
        if (i4 != 0 && i5 != 0 && i4 != i5) {
            return false;
        }
        int size = size();
        if (size > c0302g.size()) {
            throw new IllegalArgumentException("Length too large: " + size + size());
        }
        if (size > c0302g.size()) {
            StringBuilder sbI = S.i("Ran off end of other: 0, ", size, ", ");
            sbI.append(c0302g.size());
            throw new IllegalArgumentException(sbI.toString());
        }
        int iK = k() + size;
        int iK2 = k();
        int iK3 = c0302g.k();
        while (iK2 < iK) {
            if (this.f3790d[iK2] != c0302g.f3790d[iK3]) {
                return false;
            }
            iK2++;
            iK3++;
        }
        return true;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0303h
    public byte f(int i4) {
        return this.f3790d[i4];
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0303h
    public void i(byte[] bArr, int i4) {
        System.arraycopy(this.f3790d, 0, bArr, 0, i4);
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        return new C0193d(this);
    }

    public int k() {
        return 0;
    }

    public byte l(int i4) {
        return this.f3790d[i4];
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0303h
    public int size() {
        return this.f3790d.length;
    }
}
