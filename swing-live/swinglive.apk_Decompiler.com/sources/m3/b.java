package M3;

import java.util.Iterator;
import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
public final class b implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1091a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1092b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f1093c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1094d;

    public b(char c5, char c6, int i4) {
        this.f1091a = i4;
        this.f1092b = c6;
        boolean z4 = false;
        if (i4 <= 0 ? c5 >= c6 : c5 < c6 || c5 == c6) {
            z4 = true;
        }
        this.f1093c = z4;
        this.f1094d = z4 ? c5 : c6;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.f1093c;
    }

    @Override // java.util.Iterator
    public final Object next() {
        int i4 = this.f1094d;
        if (i4 != this.f1092b) {
            this.f1094d = this.f1091a + i4;
        } else {
            if (!this.f1093c) {
                throw new NoSuchElementException();
            }
            this.f1093c = false;
        }
        return Character.valueOf((char) i4);
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException("Operation is not supported for read-only collection");
    }
}
