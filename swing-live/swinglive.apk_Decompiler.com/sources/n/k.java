package n;

import java.util.ConcurrentModificationException;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class k {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static Object[] f5851d;
    public static int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static Object[] f5852f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static int f5853m;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int[] f5854a = d.f5834a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object[] f5855b = d.f5835b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5856c = 0;

    public static void b(int[] iArr, Object[] objArr, int i4) {
        if (iArr.length == 8) {
            synchronized (k.class) {
                try {
                    if (f5853m < 10) {
                        objArr[0] = f5852f;
                        objArr[1] = iArr;
                        for (int i5 = (i4 << 1) - 1; i5 >= 2; i5--) {
                            objArr[i5] = null;
                        }
                        f5852f = objArr;
                        f5853m++;
                    }
                } finally {
                }
            }
            return;
        }
        if (iArr.length == 4) {
            synchronized (k.class) {
                try {
                    if (e < 10) {
                        objArr[0] = f5851d;
                        objArr[1] = iArr;
                        for (int i6 = (i4 << 1) - 1; i6 >= 2; i6--) {
                            objArr[i6] = null;
                        }
                        f5851d = objArr;
                        e++;
                    }
                } finally {
                }
            }
        }
    }

    public final void a(int i4) {
        if (i4 == 8) {
            synchronized (k.class) {
                try {
                    Object[] objArr = f5852f;
                    if (objArr != null) {
                        this.f5855b = objArr;
                        f5852f = (Object[]) objArr[0];
                        this.f5854a = (int[]) objArr[1];
                        objArr[1] = null;
                        objArr[0] = null;
                        f5853m--;
                        return;
                    }
                } finally {
                }
            }
        } else if (i4 == 4) {
            synchronized (k.class) {
                try {
                    Object[] objArr2 = f5851d;
                    if (objArr2 != null) {
                        this.f5855b = objArr2;
                        f5851d = (Object[]) objArr2[0];
                        this.f5854a = (int[]) objArr2[1];
                        objArr2[1] = null;
                        objArr2[0] = null;
                        e--;
                        return;
                    }
                } finally {
                }
            }
        }
        this.f5854a = new int[i4];
        this.f5855b = new Object[i4 << 1];
    }

    public final int c(int i4, Object obj) {
        int i5 = this.f5856c;
        if (i5 == 0) {
            return -1;
        }
        try {
            int iA = d.a(i5, i4, this.f5854a);
            if (iA < 0 || obj.equals(this.f5855b[iA << 1])) {
                return iA;
            }
            int i6 = iA + 1;
            while (i6 < i5 && this.f5854a[i6] == i4) {
                if (obj.equals(this.f5855b[i6 << 1])) {
                    return i6;
                }
                i6++;
            }
            for (int i7 = iA - 1; i7 >= 0 && this.f5854a[i7] == i4; i7--) {
                if (obj.equals(this.f5855b[i7 << 1])) {
                    return i7;
                }
            }
            return ~i6;
        } catch (ArrayIndexOutOfBoundsException unused) {
            throw new ConcurrentModificationException();
        }
    }

    public final void clear() {
        int i4 = this.f5856c;
        if (i4 > 0) {
            int[] iArr = this.f5854a;
            Object[] objArr = this.f5855b;
            this.f5854a = d.f5834a;
            this.f5855b = d.f5835b;
            this.f5856c = 0;
            b(iArr, objArr, i4);
        }
        if (this.f5856c > 0) {
            throw new ConcurrentModificationException();
        }
    }

    public final boolean containsKey(Object obj) {
        return d(obj) >= 0;
    }

    public final boolean containsValue(Object obj) {
        return f(obj) >= 0;
    }

    public final int d(Object obj) {
        return obj == null ? e() : c(obj.hashCode(), obj);
    }

    public final int e() {
        int i4 = this.f5856c;
        if (i4 == 0) {
            return -1;
        }
        try {
            int iA = d.a(i4, 0, this.f5854a);
            if (iA < 0 || this.f5855b[iA << 1] == null) {
                return iA;
            }
            int i5 = iA + 1;
            while (i5 < i4 && this.f5854a[i5] == 0) {
                if (this.f5855b[i5 << 1] == null) {
                    return i5;
                }
                i5++;
            }
            for (int i6 = iA - 1; i6 >= 0 && this.f5854a[i6] == 0; i6--) {
                if (this.f5855b[i6 << 1] == null) {
                    return i6;
                }
            }
            return ~i5;
        } catch (ArrayIndexOutOfBoundsException unused) {
            throw new ConcurrentModificationException();
        }
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof k) {
            k kVar = (k) obj;
            if (this.f5856c != kVar.f5856c) {
                return false;
            }
            for (int i4 = 0; i4 < this.f5856c; i4++) {
                try {
                    Object objG = g(i4);
                    Object objI = i(i4);
                    Object orDefault = kVar.getOrDefault(objG, null);
                    if (objI == null) {
                        if (orDefault != null || !kVar.containsKey(objG)) {
                            return false;
                        }
                    } else if (!objI.equals(orDefault)) {
                        return false;
                    }
                } catch (ClassCastException | NullPointerException unused) {
                    return false;
                }
            }
            return true;
        }
        if (obj instanceof Map) {
            Map map = (Map) obj;
            if (this.f5856c != map.size()) {
                return false;
            }
            for (int i5 = 0; i5 < this.f5856c; i5++) {
                try {
                    Object objG2 = g(i5);
                    Object objI2 = i(i5);
                    Object obj2 = map.get(objG2);
                    if (objI2 == null) {
                        if (obj2 != null || !map.containsKey(objG2)) {
                            return false;
                        }
                    } else if (!objI2.equals(obj2)) {
                        return false;
                    }
                } catch (ClassCastException | NullPointerException unused2) {
                }
            }
            return true;
        }
        return false;
    }

    public final int f(Object obj) {
        int i4 = this.f5856c * 2;
        Object[] objArr = this.f5855b;
        if (obj == null) {
            for (int i5 = 1; i5 < i4; i5 += 2) {
                if (objArr[i5] == null) {
                    return i5 >> 1;
                }
            }
            return -1;
        }
        for (int i6 = 1; i6 < i4; i6 += 2) {
            if (obj.equals(objArr[i6])) {
                return i6 >> 1;
            }
        }
        return -1;
    }

    public final Object g(int i4) {
        return this.f5855b[i4 << 1];
    }

    public final Object get(Object obj) {
        return getOrDefault(obj, null);
    }

    public final Object getOrDefault(Object obj, Object obj2) {
        int iD = d(obj);
        return iD >= 0 ? this.f5855b[(iD << 1) + 1] : obj2;
    }

    public final Object h(int i4) {
        Object[] objArr = this.f5855b;
        int i5 = i4 << 1;
        Object obj = objArr[i5 + 1];
        int i6 = this.f5856c;
        int i7 = 0;
        if (i6 <= 1) {
            b(this.f5854a, objArr, i6);
            this.f5854a = d.f5834a;
            this.f5855b = d.f5835b;
        } else {
            int i8 = i6 - 1;
            int[] iArr = this.f5854a;
            if (iArr.length <= 8 || i6 >= iArr.length / 3) {
                if (i4 < i8) {
                    int i9 = i4 + 1;
                    int i10 = i8 - i4;
                    System.arraycopy(iArr, i9, iArr, i4, i10);
                    Object[] objArr2 = this.f5855b;
                    System.arraycopy(objArr2, i9 << 1, objArr2, i5, i10 << 1);
                }
                Object[] objArr3 = this.f5855b;
                int i11 = i8 << 1;
                objArr3[i11] = null;
                objArr3[i11 + 1] = null;
            } else {
                a(i6 > 8 ? i6 + (i6 >> 1) : 8);
                if (i6 != this.f5856c) {
                    throw new ConcurrentModificationException();
                }
                if (i4 > 0) {
                    System.arraycopy(iArr, 0, this.f5854a, 0, i4);
                    System.arraycopy(objArr, 0, this.f5855b, 0, i5);
                }
                if (i4 < i8) {
                    int i12 = i4 + 1;
                    int i13 = i8 - i4;
                    System.arraycopy(iArr, i12, this.f5854a, i4, i13);
                    System.arraycopy(objArr, i12 << 1, this.f5855b, i5, i13 << 1);
                }
            }
            i7 = i8;
        }
        if (i6 != this.f5856c) {
            throw new ConcurrentModificationException();
        }
        this.f5856c = i7;
        return obj;
    }

    public final int hashCode() {
        int[] iArr = this.f5854a;
        Object[] objArr = this.f5855b;
        int i4 = this.f5856c;
        int i5 = 1;
        int i6 = 0;
        int iHashCode = 0;
        while (i6 < i4) {
            Object obj = objArr[i5];
            iHashCode += (obj == null ? 0 : obj.hashCode()) ^ iArr[i6];
            i6++;
            i5 += 2;
        }
        return iHashCode;
    }

    public final Object i(int i4) {
        return this.f5855b[(i4 << 1) + 1];
    }

    public final boolean isEmpty() {
        return this.f5856c <= 0;
    }

    public final Object put(Object obj, Object obj2) {
        int i4;
        int iC;
        int i5 = this.f5856c;
        if (obj == null) {
            iC = e();
            i4 = 0;
        } else {
            int iHashCode = obj.hashCode();
            i4 = iHashCode;
            iC = c(iHashCode, obj);
        }
        if (iC >= 0) {
            int i6 = (iC << 1) + 1;
            Object[] objArr = this.f5855b;
            Object obj3 = objArr[i6];
            objArr[i6] = obj2;
            return obj3;
        }
        int i7 = ~iC;
        int[] iArr = this.f5854a;
        if (i5 >= iArr.length) {
            int i8 = 8;
            if (i5 >= 8) {
                i8 = (i5 >> 1) + i5;
            } else if (i5 < 4) {
                i8 = 4;
            }
            Object[] objArr2 = this.f5855b;
            a(i8);
            if (i5 != this.f5856c) {
                throw new ConcurrentModificationException();
            }
            int[] iArr2 = this.f5854a;
            if (iArr2.length > 0) {
                System.arraycopy(iArr, 0, iArr2, 0, iArr.length);
                System.arraycopy(objArr2, 0, this.f5855b, 0, objArr2.length);
            }
            b(iArr, objArr2, i5);
        }
        if (i7 < i5) {
            int[] iArr3 = this.f5854a;
            int i9 = i7 + 1;
            System.arraycopy(iArr3, i7, iArr3, i9, i5 - i7);
            Object[] objArr3 = this.f5855b;
            System.arraycopy(objArr3, i7 << 1, objArr3, i9 << 1, (this.f5856c - i7) << 1);
        }
        int i10 = this.f5856c;
        if (i5 == i10) {
            int[] iArr4 = this.f5854a;
            if (i7 < iArr4.length) {
                iArr4[i7] = i4;
                Object[] objArr4 = this.f5855b;
                int i11 = i7 << 1;
                objArr4[i11] = obj;
                objArr4[i11 + 1] = obj2;
                this.f5856c = i10 + 1;
                return null;
            }
        }
        throw new ConcurrentModificationException();
    }

    public final Object putIfAbsent(Object obj, Object obj2) {
        Object orDefault = getOrDefault(obj, null);
        return orDefault == null ? put(obj, obj2) : orDefault;
    }

    public final Object remove(Object obj) {
        int iD = d(obj);
        if (iD >= 0) {
            return h(iD);
        }
        return null;
    }

    public final Object replace(Object obj, Object obj2) {
        int iD = d(obj);
        if (iD < 0) {
            return null;
        }
        int i4 = (iD << 1) + 1;
        Object[] objArr = this.f5855b;
        Object obj3 = objArr[i4];
        objArr[i4] = obj2;
        return obj3;
    }

    public final int size() {
        return this.f5856c;
    }

    public final String toString() {
        if (isEmpty()) {
            return "{}";
        }
        StringBuilder sb = new StringBuilder(this.f5856c * 28);
        sb.append('{');
        for (int i4 = 0; i4 < this.f5856c; i4++) {
            if (i4 > 0) {
                sb.append(", ");
            }
            Object objG = g(i4);
            if (objG != this) {
                sb.append(objG);
            } else {
                sb.append("(this Map)");
            }
            sb.append('=');
            Object objI = i(i4);
            if (objI != this) {
                sb.append(objI);
            } else {
                sb.append("(this Map)");
            }
        }
        sb.append('}');
        return sb.toString();
    }

    public final boolean remove(Object obj, Object obj2) {
        int iD = d(obj);
        if (iD < 0) {
            return false;
        }
        Object objI = i(iD);
        if (obj2 != objI && (obj2 == null || !obj2.equals(objI))) {
            return false;
        }
        h(iD);
        return true;
    }

    public final boolean replace(Object obj, Object obj2, Object obj3) {
        int iD = d(obj);
        if (iD < 0) {
            return false;
        }
        Object objI = i(iD);
        if (objI != obj2 && (obj2 == null || !obj2.equals(objI))) {
            return false;
        }
        int i4 = (iD << 1) + 1;
        Object[] objArr = this.f5855b;
        Object obj4 = objArr[i4];
        objArr[i4] = obj3;
        return true;
    }
}
