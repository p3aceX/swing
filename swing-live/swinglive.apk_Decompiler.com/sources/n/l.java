package n;

/* JADX INFO: loaded from: classes.dex */
public final class l implements Cloneable {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final Object f5857d = new Object();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int[] f5858a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object[] f5859b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5860c;

    public l() {
        int i4;
        int i5 = 4;
        while (true) {
            i4 = 40;
            if (i5 >= 32) {
                break;
            }
            int i6 = (1 << i5) - 12;
            if (40 <= i6) {
                i4 = i6;
                break;
            }
            i5++;
        }
        int i7 = i4 / 4;
        this.f5858a = new int[i7];
        this.f5859b = new Object[i7];
    }

    public final void a(int i4, Object obj) {
        int i5 = this.f5860c;
        if (i5 != 0 && i4 <= this.f5858a[i5 - 1]) {
            c(i4, obj);
            return;
        }
        if (i5 >= this.f5858a.length) {
            int i6 = (i5 + 1) * 4;
            int i7 = 4;
            while (true) {
                if (i7 >= 32) {
                    break;
                }
                int i8 = (1 << i7) - 12;
                if (i6 <= i8) {
                    i6 = i8;
                    break;
                }
                i7++;
            }
            int i9 = i6 / 4;
            int[] iArr = new int[i9];
            Object[] objArr = new Object[i9];
            int[] iArr2 = this.f5858a;
            System.arraycopy(iArr2, 0, iArr, 0, iArr2.length);
            Object[] objArr2 = this.f5859b;
            System.arraycopy(objArr2, 0, objArr, 0, objArr2.length);
            this.f5858a = iArr;
            this.f5859b = objArr;
        }
        this.f5858a[i5] = i4;
        this.f5859b[i5] = obj;
        this.f5860c = i5 + 1;
    }

    public final Object b(int i4, Integer num) {
        Object obj;
        int iA = d.a(this.f5860c, i4, this.f5858a);
        return (iA < 0 || (obj = this.f5859b[iA]) == f5857d) ? num : obj;
    }

    public final void c(int i4, Object obj) {
        int iA = d.a(this.f5860c, i4, this.f5858a);
        if (iA >= 0) {
            this.f5859b[iA] = obj;
            return;
        }
        int i5 = ~iA;
        int i6 = this.f5860c;
        if (i5 < i6) {
            Object[] objArr = this.f5859b;
            if (objArr[i5] == f5857d) {
                this.f5858a[i5] = i4;
                objArr[i5] = obj;
                return;
            }
        }
        if (i6 >= this.f5858a.length) {
            int i7 = (i6 + 1) * 4;
            int i8 = 4;
            while (true) {
                if (i8 >= 32) {
                    break;
                }
                int i9 = (1 << i8) - 12;
                if (i7 <= i9) {
                    i7 = i9;
                    break;
                }
                i8++;
            }
            int i10 = i7 / 4;
            int[] iArr = new int[i10];
            Object[] objArr2 = new Object[i10];
            int[] iArr2 = this.f5858a;
            System.arraycopy(iArr2, 0, iArr, 0, iArr2.length);
            Object[] objArr3 = this.f5859b;
            System.arraycopy(objArr3, 0, objArr2, 0, objArr3.length);
            this.f5858a = iArr;
            this.f5859b = objArr2;
        }
        int i11 = this.f5860c - i5;
        if (i11 != 0) {
            int[] iArr3 = this.f5858a;
            int i12 = i5 + 1;
            System.arraycopy(iArr3, i5, iArr3, i12, i11);
            Object[] objArr4 = this.f5859b;
            System.arraycopy(objArr4, i5, objArr4, i12, this.f5860c - i5);
        }
        this.f5858a[i5] = i4;
        this.f5859b[i5] = obj;
        this.f5860c++;
    }

    public final Object clone() {
        try {
            l lVar = (l) super.clone();
            lVar.f5858a = (int[]) this.f5858a.clone();
            lVar.f5859b = (Object[]) this.f5859b.clone();
            return lVar;
        } catch (CloneNotSupportedException e) {
            throw new AssertionError(e);
        }
    }

    public final String toString() {
        int i4 = this.f5860c;
        if (i4 <= 0) {
            return "{}";
        }
        StringBuilder sb = new StringBuilder(i4 * 28);
        sb.append('{');
        for (int i5 = 0; i5 < this.f5860c; i5++) {
            if (i5 > 0) {
                sb.append(", ");
            }
            sb.append(this.f5858a[i5]);
            sb.append('=');
            Object obj = this.f5859b[i5];
            if (obj != this) {
                sb.append(obj);
            } else {
                sb.append("(this Map)");
            }
        }
        sb.append('}');
        return sb.toString();
    }
}
