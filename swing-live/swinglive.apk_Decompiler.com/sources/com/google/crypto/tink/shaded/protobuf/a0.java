package com.google.crypto.tink.shaded.protobuf;

import java.util.AbstractList;
import java.util.Arrays;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
public final class a0 extends AbstractC0297b implements RandomAccess {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final a0 f3769d;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object[] f3770b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f3771c;

    static {
        a0 a0Var = new a0(new Object[0], 0);
        f3769d = a0Var;
        a0Var.f3772a = false;
    }

    public a0(Object[] objArr, int i4) {
        this.f3770b = objArr;
        this.f3771c = i4;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0297b, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean add(Object obj) {
        f();
        int i4 = this.f3771c;
        Object[] objArr = this.f3770b;
        if (i4 == objArr.length) {
            this.f3770b = Arrays.copyOf(objArr, ((i4 * 3) / 2) + 1);
        }
        Object[] objArr2 = this.f3770b;
        int i5 = this.f3771c;
        this.f3771c = i5 + 1;
        objArr2[i5] = obj;
        ((AbstractList) this).modCount++;
        return true;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.InterfaceC0319y
    public final InterfaceC0319y c(int i4) {
        if (i4 >= this.f3771c) {
            return new a0(Arrays.copyOf(this.f3770b, i4), this.f3771c);
        }
        throw new IllegalArgumentException();
    }

    public final void g(int i4) {
        if (i4 < 0 || i4 >= this.f3771c) {
            StringBuilder sbI = S.i("Index:", i4, ", Size:");
            sbI.append(this.f3771c);
            throw new IndexOutOfBoundsException(sbI.toString());
        }
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object get(int i4) {
        g(i4);
        return this.f3770b[i4];
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0297b, java.util.AbstractList, java.util.List
    public final Object remove(int i4) {
        f();
        g(i4);
        Object[] objArr = this.f3770b;
        Object obj = objArr[i4];
        if (i4 < this.f3771c - 1) {
            System.arraycopy(objArr, i4 + 1, objArr, i4, (r2 - i4) - 1);
        }
        this.f3771c--;
        ((AbstractList) this).modCount++;
        return obj;
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object set(int i4, Object obj) {
        f();
        g(i4);
        Object[] objArr = this.f3770b;
        Object obj2 = objArr[i4];
        objArr[i4] = obj;
        ((AbstractList) this).modCount++;
        return obj2;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.f3771c;
    }

    @Override // java.util.AbstractList, java.util.List
    public final void add(int i4, Object obj) {
        int i5;
        f();
        if (i4 >= 0 && i4 <= (i5 = this.f3771c)) {
            Object[] objArr = this.f3770b;
            if (i5 < objArr.length) {
                System.arraycopy(objArr, i4, objArr, i4 + 1, i5 - i4);
            } else {
                Object[] objArr2 = new Object[B1.a.i(i5, 3, 2, 1)];
                System.arraycopy(objArr, 0, objArr2, 0, i4);
                System.arraycopy(this.f3770b, i4, objArr2, i4 + 1, this.f3771c - i4);
                this.f3770b = objArr2;
            }
            this.f3770b[i4] = obj;
            this.f3771c++;
            ((AbstractList) this).modCount++;
            return;
        }
        StringBuilder sbI = S.i("Index:", i4, ", Size:");
        sbI.append(this.f3771c);
        throw new IndexOutOfBoundsException(sbI.toString());
    }
}
