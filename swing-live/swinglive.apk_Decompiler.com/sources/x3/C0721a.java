package x3;

import java.util.ListIterator;
import java.util.NoSuchElementException;

/* JADX INFO: renamed from: x3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0721a extends J3.a implements ListIterator {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ AbstractC0723c f6772d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0721a(AbstractC0723c abstractC0723c, int i4) {
        super(abstractC0723c);
        this.f6772d = abstractC0723c;
        int iF = abstractC0723c.f();
        if (i4 < 0 || i4 > iF) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, iF, ", size: "));
        }
        this.f814b = i4;
    }

    @Override // java.util.ListIterator
    public final void add(Object obj) {
        throw new UnsupportedOperationException("Operation is not supported for read-only collection");
    }

    @Override // java.util.ListIterator
    public final boolean hasPrevious() {
        return this.f814b > 0;
    }

    @Override // java.util.ListIterator
    public final int nextIndex() {
        return this.f814b;
    }

    @Override // java.util.ListIterator
    public final Object previous() {
        if (!hasPrevious()) {
            throw new NoSuchElementException();
        }
        int i4 = this.f814b - 1;
        this.f814b = i4;
        return this.f6772d.get(i4);
    }

    @Override // java.util.ListIterator
    public final int previousIndex() {
        return this.f814b - 1;
    }

    @Override // java.util.ListIterator
    public final void set(Object obj) {
        throw new UnsupportedOperationException("Operation is not supported for read-only collection");
    }
}
