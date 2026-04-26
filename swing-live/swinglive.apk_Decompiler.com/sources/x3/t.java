package x3;

import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Arrays;
import java.util.Iterator;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
public final class t extends AbstractC0723c implements RandomAccess {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object[] f6787a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6788b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6789c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f6790d;

    public t(Object[] objArr, int i4) {
        this.f6787a = objArr;
        if (i4 < 0) {
            throw new IllegalArgumentException(S.d(i4, "ring buffer filled size should not be negative but it is ").toString());
        }
        if (i4 <= objArr.length) {
            this.f6788b = objArr.length;
            this.f6790d = i4;
        } else {
            StringBuilder sbI = S.i("ring buffer filled size: ", i4, " cannot be larger than the buffer size: ");
            sbI.append(objArr.length);
            throw new IllegalArgumentException(sbI.toString().toString());
        }
    }

    @Override // x3.AbstractC0723c
    public final int f() {
        return this.f6790d;
    }

    public final void g(int i4) {
        if (i4 < 0) {
            throw new IllegalArgumentException(S.d(i4, "n shouldn't be negative but it is ").toString());
        }
        if (i4 > this.f6790d) {
            StringBuilder sbI = S.i("n shouldn't be greater than the buffer size: n = ", i4, ", size = ");
            sbI.append(this.f6790d);
            throw new IllegalArgumentException(sbI.toString().toString());
        }
        if (i4 > 0) {
            int i5 = this.f6789c;
            int i6 = this.f6788b;
            int i7 = (i5 + i4) % i6;
            Object[] objArr = this.f6787a;
            if (i5 > i7) {
                AbstractC0726f.g0(objArr, i5, i6);
                AbstractC0726f.g0(objArr, 0, i7);
            } else {
                AbstractC0726f.g0(objArr, i5, i7);
            }
            this.f6789c = i7;
            this.f6790d -= i4;
        }
    }

    @Override // java.util.List
    public final Object get(int i4) {
        int iF = f();
        if (i4 < 0 || i4 >= iF) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, iF, ", size: "));
        }
        return this.f6787a[(this.f6789c + i4) % this.f6788b];
    }

    @Override // x3.AbstractC0723c, java.util.List, java.util.Collection, java.lang.Iterable
    public final Iterator iterator() {
        return new P3.b(this);
    }

    @Override // x3.AbstractC0723c, java.util.List, java.util.Collection
    public final Object[] toArray() {
        return toArray(new Object[f()]);
    }

    @Override // x3.AbstractC0723c, java.util.List, java.util.Collection
    public final Object[] toArray(Object[] objArr) {
        Object[] objArr2;
        J3.i.e(objArr, "array");
        int length = objArr.length;
        int i4 = this.f6790d;
        if (length < i4) {
            objArr = Arrays.copyOf(objArr, i4);
            J3.i.d(objArr, "copyOf(...)");
        }
        int i5 = this.f6790d;
        int i6 = this.f6789c;
        int i7 = 0;
        int i8 = 0;
        while (true) {
            objArr2 = this.f6787a;
            if (i8 >= i5 || i6 >= this.f6788b) {
                break;
            }
            objArr[i8] = objArr2[i6];
            i8++;
            i6++;
        }
        while (i8 < i5) {
            objArr[i8] = objArr2[i7];
            i8++;
            i7++;
        }
        if (i5 < objArr.length) {
            objArr[i5] = null;
        }
        return objArr;
    }
}
