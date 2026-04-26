package n;

import java.lang.reflect.Array;
import java.util.Collection;
import java.util.Iterator;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public final class c implements Collection, Set {
    public static final int[] e = new int[0];

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final Object[] f5825f = new Object[0];

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static Object[] f5826m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static int f5827n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static Object[] f5828o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static int f5829p;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int[] f5830a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object[] f5831b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5832c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0557a f5833d;

    public c(int i4) {
        if (i4 == 0) {
            this.f5830a = e;
            this.f5831b = f5825f;
        } else {
            f(i4);
        }
        this.f5832c = 0;
    }

    public static void g(int[] iArr, Object[] objArr, int i4) {
        if (iArr.length == 8) {
            synchronized (c.class) {
                try {
                    if (f5829p < 10) {
                        objArr[0] = f5828o;
                        objArr[1] = iArr;
                        for (int i5 = i4 - 1; i5 >= 2; i5--) {
                            objArr[i5] = null;
                        }
                        f5828o = objArr;
                        f5829p++;
                    }
                } finally {
                }
            }
            return;
        }
        if (iArr.length == 4) {
            synchronized (c.class) {
                try {
                    if (f5827n < 10) {
                        objArr[0] = f5826m;
                        objArr[1] = iArr;
                        for (int i6 = i4 - 1; i6 >= 2; i6--) {
                            objArr[i6] = null;
                        }
                        f5826m = objArr;
                        f5827n++;
                    }
                } finally {
                }
            }
        }
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean add(Object obj) {
        int i4;
        int iH;
        if (obj == null) {
            iH = i();
            i4 = 0;
        } else {
            int iHashCode = obj.hashCode();
            i4 = iHashCode;
            iH = h(iHashCode, obj);
        }
        if (iH >= 0) {
            return false;
        }
        int i5 = ~iH;
        int i6 = this.f5832c;
        int[] iArr = this.f5830a;
        if (i6 >= iArr.length) {
            int i7 = 8;
            if (i6 >= 8) {
                i7 = (i6 >> 1) + i6;
            } else if (i6 < 4) {
                i7 = 4;
            }
            Object[] objArr = this.f5831b;
            f(i7);
            int[] iArr2 = this.f5830a;
            if (iArr2.length > 0) {
                System.arraycopy(iArr, 0, iArr2, 0, iArr.length);
                System.arraycopy(objArr, 0, this.f5831b, 0, objArr.length);
            }
            g(iArr, objArr, this.f5832c);
        }
        int i8 = this.f5832c;
        if (i5 < i8) {
            int[] iArr3 = this.f5830a;
            int i9 = i5 + 1;
            System.arraycopy(iArr3, i5, iArr3, i9, i8 - i5);
            Object[] objArr2 = this.f5831b;
            System.arraycopy(objArr2, i5, objArr2, i9, this.f5832c - i5);
        }
        this.f5830a[i5] = i4;
        this.f5831b[i5] = obj;
        this.f5832c++;
        return true;
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean addAll(Collection collection) {
        int size = collection.size() + this.f5832c;
        int[] iArr = this.f5830a;
        boolean zAdd = false;
        if (iArr.length < size) {
            Object[] objArr = this.f5831b;
            f(size);
            int i4 = this.f5832c;
            if (i4 > 0) {
                System.arraycopy(iArr, 0, this.f5830a, 0, i4);
                System.arraycopy(objArr, 0, this.f5831b, 0, this.f5832c);
            }
            g(iArr, objArr, this.f5832c);
        }
        Iterator it = collection.iterator();
        while (it.hasNext()) {
            zAdd |= add(it.next());
        }
        return zAdd;
    }

    @Override // java.util.Collection, java.util.Set
    public final void clear() {
        int i4 = this.f5832c;
        if (i4 != 0) {
            g(this.f5830a, this.f5831b, i4);
            this.f5830a = e;
            this.f5831b = f5825f;
            this.f5832c = 0;
        }
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean contains(Object obj) {
        return (obj == null ? i() : h(obj.hashCode(), obj)) >= 0;
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean containsAll(Collection collection) {
        Iterator it = collection.iterator();
        while (it.hasNext()) {
            if (!contains(it.next())) {
                return false;
            }
        }
        return true;
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof Set) {
            Set set = (Set) obj;
            if (this.f5832c != set.size()) {
                return false;
            }
            for (int i4 = 0; i4 < this.f5832c; i4++) {
                try {
                    if (!set.contains(this.f5831b[i4])) {
                        return false;
                    }
                } catch (ClassCastException | NullPointerException unused) {
                }
            }
            return true;
        }
        return false;
    }

    public final void f(int i4) {
        if (i4 == 8) {
            synchronized (c.class) {
                try {
                    Object[] objArr = f5828o;
                    if (objArr != null) {
                        this.f5831b = objArr;
                        f5828o = (Object[]) objArr[0];
                        this.f5830a = (int[]) objArr[1];
                        objArr[1] = null;
                        objArr[0] = null;
                        f5829p--;
                        return;
                    }
                } finally {
                }
            }
        } else if (i4 == 4) {
            synchronized (c.class) {
                try {
                    Object[] objArr2 = f5826m;
                    if (objArr2 != null) {
                        this.f5831b = objArr2;
                        f5826m = (Object[]) objArr2[0];
                        this.f5830a = (int[]) objArr2[1];
                        objArr2[1] = null;
                        objArr2[0] = null;
                        f5827n--;
                        return;
                    }
                } finally {
                }
            }
        }
        this.f5830a = new int[i4];
        this.f5831b = new Object[i4];
    }

    public final int h(int i4, Object obj) {
        int i5 = this.f5832c;
        if (i5 == 0) {
            return -1;
        }
        int iA = d.a(i5, i4, this.f5830a);
        if (iA < 0 || obj.equals(this.f5831b[iA])) {
            return iA;
        }
        int i6 = iA + 1;
        while (i6 < i5 && this.f5830a[i6] == i4) {
            if (obj.equals(this.f5831b[i6])) {
                return i6;
            }
            i6++;
        }
        for (int i7 = iA - 1; i7 >= 0 && this.f5830a[i7] == i4; i7--) {
            if (obj.equals(this.f5831b[i7])) {
                return i7;
            }
        }
        return ~i6;
    }

    @Override // java.util.Collection, java.util.Set
    public final int hashCode() {
        int[] iArr = this.f5830a;
        int i4 = this.f5832c;
        int i5 = 0;
        for (int i6 = 0; i6 < i4; i6++) {
            i5 += iArr[i6];
        }
        return i5;
    }

    public final int i() {
        int i4 = this.f5832c;
        if (i4 == 0) {
            return -1;
        }
        int iA = d.a(i4, 0, this.f5830a);
        if (iA < 0 || this.f5831b[iA] == null) {
            return iA;
        }
        int i5 = iA + 1;
        while (i5 < i4 && this.f5830a[i5] == 0) {
            if (this.f5831b[i5] == null) {
                return i5;
            }
            i5++;
        }
        for (int i6 = iA - 1; i6 >= 0 && this.f5830a[i6] == 0; i6--) {
            if (this.f5831b[i6] == null) {
                return i6;
            }
        }
        return ~i5;
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean isEmpty() {
        return this.f5832c <= 0;
    }

    @Override // java.util.Collection, java.lang.Iterable, java.util.Set
    public final Iterator iterator() {
        if (this.f5833d == null) {
            this.f5833d = new C0557a(this, 1);
        }
        C0557a c0557a = this.f5833d;
        if (((h) c0557a.f2471b) == null) {
            c0557a.f2471b = new h(c0557a, 1);
        }
        return ((h) c0557a.f2471b).iterator();
    }

    public final void j(int i4) {
        Object[] objArr = this.f5831b;
        Object obj = objArr[i4];
        int i5 = this.f5832c;
        if (i5 <= 1) {
            g(this.f5830a, objArr, i5);
            this.f5830a = e;
            this.f5831b = f5825f;
            this.f5832c = 0;
            return;
        }
        int[] iArr = this.f5830a;
        if (iArr.length <= 8 || i5 >= iArr.length / 3) {
            int i6 = i5 - 1;
            this.f5832c = i6;
            if (i4 < i6) {
                int i7 = i4 + 1;
                System.arraycopy(iArr, i7, iArr, i4, i6 - i4);
                Object[] objArr2 = this.f5831b;
                System.arraycopy(objArr2, i7, objArr2, i4, this.f5832c - i4);
            }
            this.f5831b[this.f5832c] = null;
            return;
        }
        f(i5 > 8 ? i5 + (i5 >> 1) : 8);
        this.f5832c--;
        if (i4 > 0) {
            System.arraycopy(iArr, 0, this.f5830a, 0, i4);
            System.arraycopy(objArr, 0, this.f5831b, 0, i4);
        }
        int i8 = this.f5832c;
        if (i4 < i8) {
            int i9 = i4 + 1;
            System.arraycopy(iArr, i9, this.f5830a, i4, i8 - i4);
            System.arraycopy(objArr, i9, this.f5831b, i4, this.f5832c - i4);
        }
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean remove(Object obj) {
        int i4 = obj == null ? i() : h(obj.hashCode(), obj);
        if (i4 < 0) {
            return false;
        }
        j(i4);
        return true;
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean removeAll(Collection collection) {
        Iterator it = collection.iterator();
        boolean zRemove = false;
        while (it.hasNext()) {
            zRemove |= remove(it.next());
        }
        return zRemove;
    }

    @Override // java.util.Collection, java.util.Set
    public final boolean retainAll(Collection collection) {
        boolean z4 = false;
        for (int i4 = this.f5832c - 1; i4 >= 0; i4--) {
            if (!collection.contains(this.f5831b[i4])) {
                j(i4);
                z4 = true;
            }
        }
        return z4;
    }

    @Override // java.util.Collection, java.util.Set
    public final int size() {
        return this.f5832c;
    }

    @Override // java.util.Collection, java.util.Set
    public final Object[] toArray() {
        int i4 = this.f5832c;
        Object[] objArr = new Object[i4];
        System.arraycopy(this.f5831b, 0, objArr, 0, i4);
        return objArr;
    }

    public final String toString() {
        if (isEmpty()) {
            return "{}";
        }
        StringBuilder sb = new StringBuilder(this.f5832c * 14);
        sb.append('{');
        for (int i4 = 0; i4 < this.f5832c; i4++) {
            if (i4 > 0) {
                sb.append(", ");
            }
            Object obj = this.f5831b[i4];
            if (obj != this) {
                sb.append(obj);
            } else {
                sb.append("(this Set)");
            }
        }
        sb.append('}');
        return sb.toString();
    }

    @Override // java.util.Collection, java.util.Set
    public final Object[] toArray(Object[] objArr) {
        if (objArr.length < this.f5832c) {
            objArr = (Object[]) Array.newInstance(objArr.getClass().getComponentType(), this.f5832c);
        }
        System.arraycopy(this.f5831b, 0, objArr, 0, this.f5832c);
        int length = objArr.length;
        int i4 = this.f5832c;
        if (length > i4) {
            objArr[i4] = null;
        }
        return objArr;
    }
}
