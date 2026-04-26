package n;

import java.util.Iterator;
import java.util.NoSuchElementException;

/* JADX INFO: loaded from: classes.dex */
public final class g implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f5840a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5841b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5842c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f5843d = false;
    public final /* synthetic */ Y0.d e;

    public g(Y0.d dVar, int i4) {
        this.e = dVar;
        this.f5840a = i4;
        this.f5841b = dVar.d();
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.f5842c < this.f5841b;
    }

    @Override // java.util.Iterator
    public final Object next() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        Object objB = this.e.b(this.f5842c, this.f5840a);
        this.f5842c++;
        this.f5843d = true;
        return objB;
    }

    @Override // java.util.Iterator
    public final void remove() {
        if (!this.f5843d) {
            throw new IllegalStateException();
        }
        int i4 = this.f5842c - 1;
        this.f5842c = i4;
        this.f5841b--;
        this.f5843d = false;
        this.e.h(i4);
    }
}
