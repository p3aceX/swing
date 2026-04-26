package P3;

import a.AbstractC0184a;
import java.util.Iterator;
import java.util.NoSuchElementException;
import x3.t;

/* JADX INFO: loaded from: classes.dex */
public final class b implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1494a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1495b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f1496c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1497d;
    public Object e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ Object f1498f;

    public b(t tVar) {
        this.f1494a = 1;
        this.f1498f = tVar;
        this.f1496c = tVar.f6790d;
        this.f1497d = tVar.f6789c;
    }

    public void a() {
        w3.c cVar;
        int i4 = this.f1497d;
        if (i4 < 0) {
            this.f1495b = 0;
            this.e = null;
            return;
        }
        c cVar2 = (c) this.f1498f;
        cVar2.getClass();
        CharSequence charSequence = cVar2.f1499a;
        if (i4 <= charSequence.length() && (cVar = (w3.c) cVar2.f1500b.invoke(charSequence, Integer.valueOf(this.f1497d))) != null) {
            int iIntValue = ((Number) cVar.f6718a).intValue();
            int iIntValue2 = ((Number) cVar.f6719b).intValue();
            this.e = AbstractC0184a.Z(this.f1496c, iIntValue);
            int i5 = iIntValue + iIntValue2;
            this.f1496c = i5;
            this.f1497d = i5 + (iIntValue2 == 0 ? 1 : 0);
        } else {
            this.e = new M3.f(this.f1496c, m.s0(charSequence), 1);
            this.f1497d = -1;
        }
        this.f1495b = 1;
    }

    public boolean b() {
        this.f1495b = 3;
        int i4 = this.f1496c;
        if (i4 == 0) {
            this.f1495b = 2;
        } else {
            t tVar = (t) this.f1498f;
            Object[] objArr = tVar.f6787a;
            int i5 = this.f1497d;
            this.e = objArr[i5];
            this.f1495b = 1;
            this.f1497d = (i5 + 1) % tVar.f6788b;
            this.f1496c = i4 - 1;
        }
        return this.f1495b == 1;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        switch (this.f1494a) {
            case 0:
                if (this.f1495b == -1) {
                    a();
                }
                return this.f1495b == 1;
            default:
                int i4 = this.f1495b;
                if (i4 == 0) {
                    return b();
                }
                if (i4 == 1) {
                    return true;
                }
                if (i4 == 2) {
                    return false;
                }
                throw new IllegalArgumentException("hasNext called when the iterator is in the FAILED state.");
        }
    }

    @Override // java.util.Iterator
    public final Object next() {
        switch (this.f1494a) {
            case 0:
                if (this.f1495b == -1) {
                    a();
                }
                if (this.f1495b == 0) {
                    throw new NoSuchElementException();
                }
                M3.f fVar = (M3.f) this.e;
                J3.i.c(fVar, "null cannot be cast to non-null type kotlin.ranges.IntRange");
                this.e = null;
                this.f1495b = -1;
                return fVar;
            default:
                int i4 = this.f1495b;
                if (i4 == 1) {
                    this.f1495b = 0;
                    return this.e;
                }
                if (i4 == 2 || !b()) {
                    throw new NoSuchElementException();
                }
                this.f1495b = 0;
                return this.e;
        }
    }

    @Override // java.util.Iterator
    public final void remove() {
        switch (this.f1494a) {
            case 0:
                throw new UnsupportedOperationException("Operation is not supported for read-only collection");
            default:
                throw new UnsupportedOperationException("Operation is not supported for read-only collection");
        }
    }

    public b(c cVar) {
        this.f1494a = 0;
        this.f1498f = cVar;
        this.f1495b = -1;
        cVar.getClass();
        int length = cVar.f1499a.length();
        if (length >= 0) {
            length = length >= 0 ? 0 : length;
            this.f1496c = length;
            this.f1497d = length;
        } else {
            throw new IllegalArgumentException("Cannot coerce value to an empty range: maximum " + length + " is less than minimum 0.");
        }
    }
}
