package M3;

import java.util.Iterator;
import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1098a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f1099b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f1100c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f1101d;

    public e(int i4, int i5, int i6) {
        this.f1098a = i6;
        this.f1099b = i5;
        boolean z4 = false;
        if (i6 <= 0 ? i4 >= i5 : i4 <= i5) {
            z4 = true;
        }
        this.f1100c = z4;
        this.f1101d = z4 ? i4 : i5;
    }

    public final int a() {
        int i4 = this.f1101d;
        if (i4 != this.f1099b) {
            this.f1101d = this.f1098a + i4;
            return i4;
        }
        if (!this.f1100c) {
            throw new NoSuchElementException();
        }
        this.f1100c = false;
        return i4;
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.f1100c;
    }

    @Override // java.util.Iterator
    public final /* bridge */ /* synthetic */ Object next() {
        return Integer.valueOf(a());
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException("Operation is not supported for read-only collection");
    }
}
