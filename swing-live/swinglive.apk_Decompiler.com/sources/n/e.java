package n;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Cloneable {
    public static final Object e = new Object();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public boolean f5836a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public long[] f5837b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object[] f5838c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5839d;

    public e() {
        int i4;
        int i5 = 4;
        while (true) {
            i4 = 80;
            if (i5 >= 32) {
                break;
            }
            int i6 = (1 << i5) - 12;
            if (80 <= i6) {
                i4 = i6;
                break;
            }
            i5++;
        }
        int i7 = i4 / 8;
        this.f5837b = new long[i7];
        this.f5838c = new Object[i7];
    }

    public final void a() {
        int i4 = this.f5839d;
        long[] jArr = this.f5837b;
        Object[] objArr = this.f5838c;
        int i5 = 0;
        for (int i6 = 0; i6 < i4; i6++) {
            Object obj = objArr[i6];
            if (obj != e) {
                if (i6 != i5) {
                    jArr[i5] = jArr[i6];
                    objArr[i5] = obj;
                    objArr[i6] = null;
                }
                i5++;
            }
        }
        this.f5836a = false;
        this.f5839d = i5;
    }

    public final void b(Object obj, long j4) {
        int iB = d.b(this.f5837b, this.f5839d, j4);
        if (iB >= 0) {
            this.f5838c[iB] = obj;
            return;
        }
        int i4 = ~iB;
        int i5 = this.f5839d;
        if (i4 < i5) {
            Object[] objArr = this.f5838c;
            if (objArr[i4] == e) {
                this.f5837b[i4] = j4;
                objArr[i4] = obj;
                return;
            }
        }
        if (this.f5836a && i5 >= this.f5837b.length) {
            a();
            i4 = ~d.b(this.f5837b, this.f5839d, j4);
        }
        int i6 = this.f5839d;
        if (i6 >= this.f5837b.length) {
            int i7 = (i6 + 1) * 8;
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
            int i10 = i7 / 8;
            long[] jArr = new long[i10];
            Object[] objArr2 = new Object[i10];
            long[] jArr2 = this.f5837b;
            System.arraycopy(jArr2, 0, jArr, 0, jArr2.length);
            Object[] objArr3 = this.f5838c;
            System.arraycopy(objArr3, 0, objArr2, 0, objArr3.length);
            this.f5837b = jArr;
            this.f5838c = objArr2;
        }
        int i11 = this.f5839d - i4;
        if (i11 != 0) {
            long[] jArr3 = this.f5837b;
            int i12 = i4 + 1;
            System.arraycopy(jArr3, i4, jArr3, i12, i11);
            Object[] objArr4 = this.f5838c;
            System.arraycopy(objArr4, i4, objArr4, i12, this.f5839d - i4);
        }
        this.f5837b[i4] = j4;
        this.f5838c[i4] = obj;
        this.f5839d++;
    }

    public final Object clone() {
        try {
            e eVar = (e) super.clone();
            eVar.f5837b = (long[]) this.f5837b.clone();
            eVar.f5838c = (Object[]) this.f5838c.clone();
            return eVar;
        } catch (CloneNotSupportedException e4) {
            throw new AssertionError(e4);
        }
    }

    public final String toString() {
        if (this.f5836a) {
            a();
        }
        if (this.f5839d <= 0) {
            return "{}";
        }
        StringBuilder sb = new StringBuilder(this.f5839d * 28);
        sb.append('{');
        for (int i4 = 0; i4 < this.f5839d; i4++) {
            if (i4 > 0) {
                sb.append(", ");
            }
            if (this.f5836a) {
                a();
            }
            sb.append(this.f5837b[i4]);
            sb.append('=');
            if (this.f5836a) {
                a();
            }
            Object obj = this.f5838c[i4];
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
