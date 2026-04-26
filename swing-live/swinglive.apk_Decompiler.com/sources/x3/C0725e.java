package x3;

import java.lang.reflect.Array;
import java.util.AbstractList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

/* JADX INFO: renamed from: x3.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0725e extends AbstractList implements List {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final Object[] f6778d = new Object[0];

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6779a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object[] f6780b = f6778d;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f6781c;

    @Override // java.util.AbstractList, java.util.List
    public final void add(int i4, Object obj) {
        int length;
        int i5 = this.f6781c;
        if (i4 < 0 || i4 > i5) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, i5, ", size: "));
        }
        if (i4 == i5) {
            addLast(obj);
            return;
        }
        if (i4 == 0) {
            addFirst(obj);
            return;
        }
        l();
        g(this.f6781c + 1);
        int iK = k(this.f6779a + i4);
        int i6 = this.f6781c;
        if (i4 < ((i6 + 1) >> 1)) {
            if (iK == 0) {
                Object[] objArr = this.f6780b;
                J3.i.e(objArr, "<this>");
                iK = objArr.length;
            }
            int i7 = iK - 1;
            int i8 = this.f6779a;
            if (i8 == 0) {
                Object[] objArr2 = this.f6780b;
                J3.i.e(objArr2, "<this>");
                length = objArr2.length - 1;
            } else {
                length = i8 - 1;
            }
            int i9 = this.f6779a;
            if (i7 >= i9) {
                Object[] objArr3 = this.f6780b;
                objArr3[length] = objArr3[i9];
                AbstractC0726f.e0(objArr3, i9, objArr3, i9 + 1, i7 + 1);
            } else {
                Object[] objArr4 = this.f6780b;
                AbstractC0726f.e0(objArr4, i9 - 1, objArr4, i9, objArr4.length);
                Object[] objArr5 = this.f6780b;
                objArr5[objArr5.length - 1] = objArr5[0];
                AbstractC0726f.e0(objArr5, 0, objArr5, 1, i7 + 1);
            }
            this.f6780b[i7] = obj;
            this.f6779a = length;
        } else {
            int iK2 = k(this.f6779a + i6);
            if (iK < iK2) {
                Object[] objArr6 = this.f6780b;
                AbstractC0726f.e0(objArr6, iK + 1, objArr6, iK, iK2);
            } else {
                Object[] objArr7 = this.f6780b;
                AbstractC0726f.e0(objArr7, 1, objArr7, 0, iK2);
                Object[] objArr8 = this.f6780b;
                objArr8[0] = objArr8[objArr8.length - 1];
                AbstractC0726f.e0(objArr8, iK + 1, objArr8, iK, objArr8.length - 1);
            }
            this.f6780b[iK] = obj;
        }
        this.f6781c++;
    }

    @Override // java.util.AbstractList, java.util.List
    public final boolean addAll(int i4, Collection collection) {
        J3.i.e(collection, "elements");
        int i5 = this.f6781c;
        if (i4 < 0 || i4 > i5) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, i5, ", size: "));
        }
        if (collection.isEmpty()) {
            return false;
        }
        if (i4 == this.f6781c) {
            return addAll(collection);
        }
        l();
        g(collection.size() + this.f6781c);
        int iK = k(this.f6779a + this.f6781c);
        int iK2 = k(this.f6779a + i4);
        int size = collection.size();
        if (i4 >= ((this.f6781c + 1) >> 1)) {
            int i6 = iK2 + size;
            if (iK2 < iK) {
                int i7 = size + iK;
                Object[] objArr = this.f6780b;
                if (i7 <= objArr.length) {
                    AbstractC0726f.e0(objArr, i6, objArr, iK2, iK);
                } else if (i6 >= objArr.length) {
                    AbstractC0726f.e0(objArr, i6 - objArr.length, objArr, iK2, iK);
                } else {
                    int length = iK - (i7 - objArr.length);
                    AbstractC0726f.e0(objArr, 0, objArr, length, iK);
                    Object[] objArr2 = this.f6780b;
                    AbstractC0726f.e0(objArr2, i6, objArr2, iK2, length);
                }
            } else {
                Object[] objArr3 = this.f6780b;
                AbstractC0726f.e0(objArr3, size, objArr3, 0, iK);
                Object[] objArr4 = this.f6780b;
                if (i6 >= objArr4.length) {
                    AbstractC0726f.e0(objArr4, i6 - objArr4.length, objArr4, iK2, objArr4.length);
                } else {
                    AbstractC0726f.e0(objArr4, 0, objArr4, objArr4.length - size, objArr4.length);
                    Object[] objArr5 = this.f6780b;
                    AbstractC0726f.e0(objArr5, i6, objArr5, iK2, objArr5.length - size);
                }
            }
            f(iK2, collection);
            return true;
        }
        int i8 = this.f6779a;
        int length2 = i8 - size;
        if (iK2 < i8) {
            Object[] objArr6 = this.f6780b;
            AbstractC0726f.e0(objArr6, length2, objArr6, i8, objArr6.length);
            if (size >= iK2) {
                Object[] objArr7 = this.f6780b;
                AbstractC0726f.e0(objArr7, objArr7.length - size, objArr7, 0, iK2);
            } else {
                Object[] objArr8 = this.f6780b;
                AbstractC0726f.e0(objArr8, objArr8.length - size, objArr8, 0, size);
                Object[] objArr9 = this.f6780b;
                AbstractC0726f.e0(objArr9, 0, objArr9, size, iK2);
            }
        } else if (length2 >= 0) {
            Object[] objArr10 = this.f6780b;
            AbstractC0726f.e0(objArr10, length2, objArr10, i8, iK2);
        } else {
            Object[] objArr11 = this.f6780b;
            length2 += objArr11.length;
            int i9 = iK2 - i8;
            int length3 = objArr11.length - length2;
            if (length3 >= i9) {
                AbstractC0726f.e0(objArr11, length2, objArr11, i8, iK2);
            } else {
                AbstractC0726f.e0(objArr11, length2, objArr11, i8, i8 + length3);
                Object[] objArr12 = this.f6780b;
                AbstractC0726f.e0(objArr12, 0, objArr12, this.f6779a + length3, iK2);
            }
        }
        this.f6779a = length2;
        f(i(iK2 - size), collection);
        return true;
    }

    public final void addFirst(Object obj) {
        l();
        g(this.f6781c + 1);
        int length = this.f6779a;
        if (length == 0) {
            Object[] objArr = this.f6780b;
            J3.i.e(objArr, "<this>");
            length = objArr.length;
        }
        int i4 = length - 1;
        this.f6779a = i4;
        this.f6780b[i4] = obj;
        this.f6781c++;
    }

    public final void addLast(Object obj) {
        l();
        g(this.f6781c + 1);
        this.f6780b[k(this.f6779a + this.f6781c)] = obj;
        this.f6781c++;
    }

    @Override // java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final void clear() {
        if (!isEmpty()) {
            l();
            j(this.f6779a, k(this.f6779a + this.f6781c));
        }
        this.f6779a = 0;
        this.f6781c = 0;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean contains(Object obj) {
        return indexOf(obj) != -1;
    }

    public final void f(int i4, Collection collection) {
        Iterator it = collection.iterator();
        int length = this.f6780b.length;
        while (i4 < length && it.hasNext()) {
            this.f6780b[i4] = it.next();
            i4++;
        }
        int i5 = this.f6779a;
        for (int i6 = 0; i6 < i5 && it.hasNext(); i6++) {
            this.f6780b[i6] = it.next();
        }
        this.f6781c = collection.size() + this.f6781c;
    }

    public final void g(int i4) {
        if (i4 < 0) {
            throw new IllegalStateException("Deque is too big.");
        }
        Object[] objArr = this.f6780b;
        if (i4 <= objArr.length) {
            return;
        }
        if (objArr == f6778d) {
            if (i4 < 10) {
                i4 = 10;
            }
            this.f6780b = new Object[i4];
            return;
        }
        int length = objArr.length;
        int i5 = length + (length >> 1);
        if (i5 - i4 < 0) {
            i5 = i4;
        }
        if (i5 - 2147483639 > 0) {
            i5 = i4 > 2147483639 ? com.google.android.gms.common.api.f.API_PRIORITY_OTHER : 2147483639;
        }
        Object[] objArr2 = new Object[i5];
        AbstractC0726f.e0(objArr, 0, objArr2, this.f6779a, objArr.length);
        Object[] objArr3 = this.f6780b;
        int length2 = objArr3.length;
        int i6 = this.f6779a;
        AbstractC0726f.e0(objArr3, length2 - i6, objArr2, 0, i6);
        this.f6779a = 0;
        this.f6780b = objArr2;
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object get(int i4) {
        int i5 = this.f6781c;
        if (i4 < 0 || i4 >= i5) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, i5, ", size: "));
        }
        return this.f6780b[k(this.f6779a + i4)];
    }

    public final int h(int i4) {
        J3.i.e(this.f6780b, "<this>");
        if (i4 == r0.length - 1) {
            return 0;
        }
        return i4 + 1;
    }

    public final int i(int i4) {
        return i4 < 0 ? i4 + this.f6780b.length : i4;
    }

    @Override // java.util.AbstractList, java.util.List
    public final int indexOf(Object obj) {
        int i4;
        int iK = k(this.f6779a + this.f6781c);
        int length = this.f6779a;
        if (length < iK) {
            while (length < iK) {
                if (J3.i.a(obj, this.f6780b[length])) {
                    i4 = this.f6779a;
                } else {
                    length++;
                }
            }
            return -1;
        }
        if (length < iK) {
            return -1;
        }
        int length2 = this.f6780b.length;
        while (true) {
            if (length >= length2) {
                for (int i5 = 0; i5 < iK; i5++) {
                    if (J3.i.a(obj, this.f6780b[i5])) {
                        length = i5 + this.f6780b.length;
                        i4 = this.f6779a;
                    }
                }
                return -1;
            }
            if (J3.i.a(obj, this.f6780b[length])) {
                i4 = this.f6779a;
                break;
            }
            length++;
        }
        return length - i4;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean isEmpty() {
        return this.f6781c == 0;
    }

    public final void j(int i4, int i5) {
        if (i4 < i5) {
            AbstractC0726f.g0(this.f6780b, i4, i5);
            return;
        }
        Object[] objArr = this.f6780b;
        AbstractC0726f.g0(objArr, i4, objArr.length);
        AbstractC0726f.g0(this.f6780b, 0, i5);
    }

    public final int k(int i4) {
        Object[] objArr = this.f6780b;
        return i4 >= objArr.length ? i4 - objArr.length : i4;
    }

    public final void l() {
        ((AbstractList) this).modCount++;
    }

    @Override // java.util.AbstractList, java.util.List
    public final int lastIndexOf(Object obj) {
        int length;
        int i4;
        int iK = k(this.f6779a + this.f6781c);
        int i5 = this.f6779a;
        if (i5 < iK) {
            length = iK - 1;
            if (i5 <= length) {
                while (!J3.i.a(obj, this.f6780b[length])) {
                    if (length != i5) {
                        length--;
                    }
                }
                i4 = this.f6779a;
                return length - i4;
            }
            return -1;
        }
        if (i5 > iK) {
            int i6 = iK - 1;
            while (true) {
                if (-1 >= i6) {
                    Object[] objArr = this.f6780b;
                    J3.i.e(objArr, "<this>");
                    length = objArr.length - 1;
                    int i7 = this.f6779a;
                    if (i7 <= length) {
                        while (!J3.i.a(obj, this.f6780b[length])) {
                            if (length != i7) {
                                length--;
                            }
                        }
                        i4 = this.f6779a;
                    }
                } else {
                    if (J3.i.a(obj, this.f6780b[i6])) {
                        length = i6 + this.f6780b.length;
                        i4 = this.f6779a;
                        break;
                    }
                    i6--;
                }
            }
        }
        return -1;
    }

    public final Object m(int i4) {
        int i5 = this.f6781c;
        if (i4 < 0 || i4 >= i5) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, i5, ", size: "));
        }
        if (i4 == AbstractC0729i.S(this)) {
            return removeLast();
        }
        if (i4 == 0) {
            return removeFirst();
        }
        l();
        int iK = k(this.f6779a + i4);
        Object[] objArr = this.f6780b;
        Object obj = objArr[iK];
        if (i4 < (this.f6781c >> 1)) {
            int i6 = this.f6779a;
            if (iK >= i6) {
                AbstractC0726f.e0(objArr, i6 + 1, objArr, i6, iK);
            } else {
                AbstractC0726f.e0(objArr, 1, objArr, 0, iK);
                Object[] objArr2 = this.f6780b;
                objArr2[0] = objArr2[objArr2.length - 1];
                int i7 = this.f6779a;
                AbstractC0726f.e0(objArr2, i7 + 1, objArr2, i7, objArr2.length - 1);
            }
            Object[] objArr3 = this.f6780b;
            int i8 = this.f6779a;
            objArr3[i8] = null;
            this.f6779a = h(i8);
        } else {
            int iK2 = k(AbstractC0729i.S(this) + this.f6779a);
            if (iK <= iK2) {
                Object[] objArr4 = this.f6780b;
                AbstractC0726f.e0(objArr4, iK, objArr4, iK + 1, iK2 + 1);
            } else {
                Object[] objArr5 = this.f6780b;
                AbstractC0726f.e0(objArr5, iK, objArr5, iK + 1, objArr5.length);
                Object[] objArr6 = this.f6780b;
                objArr6[objArr6.length - 1] = objArr6[0];
                AbstractC0726f.e0(objArr6, 0, objArr6, 1, iK2 + 1);
            }
            this.f6780b[iK2] = null;
        }
        this.f6781c--;
        return obj;
    }

    @Override // java.util.AbstractList, java.util.List
    public final /* bridge */ Object remove(int i4) {
        return m(i4);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean removeAll(Collection collection) {
        int iK;
        J3.i.e(collection, "elements");
        boolean z4 = false;
        z4 = false;
        z4 = false;
        if (!isEmpty() && this.f6780b.length != 0) {
            int iK2 = k(this.f6779a + this.f6781c);
            int i4 = this.f6779a;
            if (i4 < iK2) {
                iK = i4;
                while (i4 < iK2) {
                    Object obj = this.f6780b[i4];
                    if (collection.contains(obj)) {
                        z4 = true;
                    } else {
                        this.f6780b[iK] = obj;
                        iK++;
                    }
                    i4++;
                }
                AbstractC0726f.g0(this.f6780b, iK, iK2);
            } else {
                int length = this.f6780b.length;
                boolean z5 = false;
                int i5 = i4;
                while (i4 < length) {
                    Object[] objArr = this.f6780b;
                    Object obj2 = objArr[i4];
                    objArr[i4] = null;
                    if (collection.contains(obj2)) {
                        z5 = true;
                    } else {
                        this.f6780b[i5] = obj2;
                        i5++;
                    }
                    i4++;
                }
                iK = k(i5);
                for (int i6 = 0; i6 < iK2; i6++) {
                    Object[] objArr2 = this.f6780b;
                    Object obj3 = objArr2[i6];
                    objArr2[i6] = null;
                    if (collection.contains(obj3)) {
                        z5 = true;
                    } else {
                        this.f6780b[iK] = obj3;
                        iK = h(iK);
                    }
                }
                z4 = z5;
            }
            if (z4) {
                l();
                this.f6781c = i(iK - this.f6779a);
            }
        }
        return z4;
    }

    public final Object removeFirst() {
        if (isEmpty()) {
            throw new NoSuchElementException("ArrayDeque is empty.");
        }
        l();
        Object[] objArr = this.f6780b;
        int i4 = this.f6779a;
        Object obj = objArr[i4];
        objArr[i4] = null;
        this.f6779a = h(i4);
        this.f6781c--;
        return obj;
    }

    public final Object removeLast() {
        if (isEmpty()) {
            throw new NoSuchElementException("ArrayDeque is empty.");
        }
        l();
        int iK = k(AbstractC0729i.S(this) + this.f6779a);
        Object[] objArr = this.f6780b;
        Object obj = objArr[iK];
        objArr[iK] = null;
        this.f6781c--;
        return obj;
    }

    @Override // java.util.AbstractList
    public final void removeRange(int i4, int i5) {
        e1.k.g(i4, i5, this.f6781c);
        int i6 = i5 - i4;
        if (i6 == 0) {
            return;
        }
        if (i6 == this.f6781c) {
            clear();
            return;
        }
        if (i6 == 1) {
            m(i4);
            return;
        }
        l();
        if (i4 < this.f6781c - i5) {
            int iK = k(this.f6779a + (i4 - 1));
            int iK2 = k(this.f6779a + (i5 - 1));
            while (i4 > 0) {
                int i7 = iK + 1;
                int iMin = Math.min(i4, Math.min(i7, iK2 + 1));
                Object[] objArr = this.f6780b;
                int i8 = iK2 - iMin;
                int i9 = iK - iMin;
                AbstractC0726f.e0(objArr, i8 + 1, objArr, i9 + 1, i7);
                iK = i(i9);
                iK2 = i(i8);
                i4 -= iMin;
            }
            int iK3 = k(this.f6779a + i6);
            j(this.f6779a, iK3);
            this.f6779a = iK3;
        } else {
            int iK4 = k(this.f6779a + i5);
            int iK5 = k(this.f6779a + i4);
            int i10 = this.f6781c;
            while (true) {
                i10 -= i5;
                if (i10 <= 0) {
                    break;
                }
                Object[] objArr2 = this.f6780b;
                i5 = Math.min(i10, Math.min(objArr2.length - iK4, objArr2.length - iK5));
                Object[] objArr3 = this.f6780b;
                int i11 = iK4 + i5;
                AbstractC0726f.e0(objArr3, iK5, objArr3, iK4, i11);
                iK4 = k(i11);
                iK5 = k(iK5 + i5);
            }
            int iK6 = k(this.f6779a + this.f6781c);
            j(i(iK6 - i6), iK6);
        }
        this.f6781c -= i6;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean retainAll(Collection collection) {
        int iK;
        J3.i.e(collection, "elements");
        boolean z4 = false;
        z4 = false;
        z4 = false;
        if (!isEmpty() && this.f6780b.length != 0) {
            int iK2 = k(this.f6779a + this.f6781c);
            int i4 = this.f6779a;
            if (i4 < iK2) {
                iK = i4;
                while (i4 < iK2) {
                    Object obj = this.f6780b[i4];
                    if (collection.contains(obj)) {
                        this.f6780b[iK] = obj;
                        iK++;
                    } else {
                        z4 = true;
                    }
                    i4++;
                }
                AbstractC0726f.g0(this.f6780b, iK, iK2);
            } else {
                int length = this.f6780b.length;
                boolean z5 = false;
                int i5 = i4;
                while (i4 < length) {
                    Object[] objArr = this.f6780b;
                    Object obj2 = objArr[i4];
                    objArr[i4] = null;
                    if (collection.contains(obj2)) {
                        this.f6780b[i5] = obj2;
                        i5++;
                    } else {
                        z5 = true;
                    }
                    i4++;
                }
                iK = k(i5);
                for (int i6 = 0; i6 < iK2; i6++) {
                    Object[] objArr2 = this.f6780b;
                    Object obj3 = objArr2[i6];
                    objArr2[i6] = null;
                    if (collection.contains(obj3)) {
                        this.f6780b[iK] = obj3;
                        iK = h(iK);
                    } else {
                        z5 = true;
                    }
                }
                z4 = z5;
            }
            if (z4) {
                l();
                this.f6781c = i(iK - this.f6779a);
            }
        }
        return z4;
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object set(int i4, Object obj) {
        int i5 = this.f6781c;
        if (i4 < 0 || i4 >= i5) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, i5, ", size: "));
        }
        int iK = k(this.f6779a + i4);
        Object[] objArr = this.f6780b;
        Object obj2 = objArr[iK];
        objArr[iK] = obj;
        return obj2;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.f6781c;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final Object[] toArray() {
        return toArray(new Object[this.f6781c]);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean remove(Object obj) {
        int iIndexOf = indexOf(obj);
        if (iIndexOf == -1) {
            return false;
        }
        m(iIndexOf);
        return true;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final Object[] toArray(Object[] objArr) {
        J3.i.e(objArr, "array");
        int length = objArr.length;
        int i4 = this.f6781c;
        if (length < i4) {
            Object objNewInstance = Array.newInstance(objArr.getClass().getComponentType(), i4);
            J3.i.c(objNewInstance, "null cannot be cast to non-null type kotlin.Array<T of kotlin.collections.ArraysKt__ArraysJVMKt.arrayOfNulls>");
            objArr = (Object[]) objNewInstance;
        }
        int iK = k(this.f6779a + this.f6781c);
        int i5 = this.f6779a;
        if (i5 < iK) {
            AbstractC0726f.e0(this.f6780b, 0, objArr, i5, iK);
        } else if (!isEmpty()) {
            Object[] objArr2 = this.f6780b;
            AbstractC0726f.e0(objArr2, 0, objArr, this.f6779a, objArr2.length);
            Object[] objArr3 = this.f6780b;
            AbstractC0726f.e0(objArr3, objArr3.length - this.f6779a, objArr, 0, iK);
        }
        int i6 = this.f6781c;
        if (i6 < objArr.length) {
            objArr[i6] = null;
        }
        return objArr;
    }

    @Override // java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean add(Object obj) {
        addLast(obj);
        return true;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean addAll(Collection collection) {
        J3.i.e(collection, "elements");
        if (collection.isEmpty()) {
            return false;
        }
        l();
        g(collection.size() + this.f6781c);
        f(k(this.f6779a + this.f6781c), collection);
        return true;
    }
}
