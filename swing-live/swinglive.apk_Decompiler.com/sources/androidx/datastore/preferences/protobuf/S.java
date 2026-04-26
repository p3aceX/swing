package androidx.datastore.preferences.protobuf;

import java.util.AbstractList;
import java.util.Arrays;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
public final class S extends AbstractC0191b implements RandomAccess {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final S f2930d = new S(new Object[0], 0, false);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object[] f2931b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2932c;

    public S(Object[] objArr, int i4, boolean z4) {
        this.f2953a = z4;
        this.f2931b = objArr;
        this.f2932c = i4;
    }

    @Override // java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean add(Object obj) {
        f();
        int i4 = this.f2932c;
        Object[] objArr = this.f2931b;
        if (i4 == objArr.length) {
            this.f2931b = Arrays.copyOf(objArr, ((i4 * 3) / 2) + 1);
        }
        Object[] objArr2 = this.f2931b;
        int i5 = this.f2932c;
        this.f2932c = i5 + 1;
        objArr2[i5] = obj;
        ((AbstractList) this).modCount++;
        return true;
    }

    public final void g(int i4) {
        if (i4 < 0 || i4 >= this.f2932c) {
            StringBuilder sbI = com.google.crypto.tink.shaded.protobuf.S.i("Index:", i4, ", Size:");
            sbI.append(this.f2932c);
            throw new IndexOutOfBoundsException(sbI.toString());
        }
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object get(int i4) {
        g(i4);
        return this.f2931b[i4];
    }

    public final S h(int i4) {
        if (i4 >= this.f2932c) {
            return new S(Arrays.copyOf(this.f2931b, i4), this.f2932c, true);
        }
        throw new IllegalArgumentException();
    }

    @Override // androidx.datastore.preferences.protobuf.AbstractC0191b, java.util.AbstractList, java.util.List
    public final Object remove(int i4) {
        f();
        g(i4);
        Object[] objArr = this.f2931b;
        Object obj = objArr[i4];
        if (i4 < this.f2932c - 1) {
            System.arraycopy(objArr, i4 + 1, objArr, i4, (r2 - i4) - 1);
        }
        this.f2932c--;
        ((AbstractList) this).modCount++;
        return obj;
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object set(int i4, Object obj) {
        f();
        g(i4);
        Object[] objArr = this.f2931b;
        Object obj2 = objArr[i4];
        objArr[i4] = obj;
        ((AbstractList) this).modCount++;
        return obj2;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.f2932c;
    }

    @Override // java.util.AbstractList, java.util.List
    public final void add(int i4, Object obj) {
        int i5;
        f();
        if (i4 >= 0 && i4 <= (i5 = this.f2932c)) {
            Object[] objArr = this.f2931b;
            if (i5 < objArr.length) {
                System.arraycopy(objArr, i4, objArr, i4 + 1, i5 - i4);
            } else {
                Object[] objArr2 = new Object[B1.a.i(i5, 3, 2, 1)];
                System.arraycopy(objArr, 0, objArr2, 0, i4);
                System.arraycopy(this.f2931b, i4, objArr2, i4 + 1, this.f2932c - i4);
                this.f2931b = objArr2;
            }
            this.f2931b[i4] = obj;
            this.f2932c++;
            ((AbstractList) this).modCount++;
            return;
        }
        StringBuilder sbI = com.google.crypto.tink.shaded.protobuf.S.i("Index:", i4, ", Size:");
        sbI.append(this.f2932c);
        throw new IndexOutOfBoundsException(sbI.toString());
    }
}
