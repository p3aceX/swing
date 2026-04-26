package x3;

import java.util.List;
import java.util.RandomAccess;

/* JADX INFO: renamed from: x3.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0722b extends AbstractC0723c implements RandomAccess {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0723c f6773a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6774b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6775c;

    public C0722b(AbstractC0723c abstractC0723c, int i4, int i5) {
        this.f6773a = abstractC0723c;
        this.f6774b = i4;
        e1.k.g(i4, i5, abstractC0723c.f());
        this.f6775c = i5 - i4;
    }

    @Override // x3.AbstractC0723c
    public final int f() {
        return this.f6775c;
    }

    @Override // java.util.List
    public final Object get(int i4) {
        int i5 = this.f6775c;
        if (i4 < 0 || i4 >= i5) {
            throw new IndexOutOfBoundsException(B1.a.k("index: ", i4, i5, ", size: "));
        }
        return this.f6773a.get(this.f6774b + i4);
    }

    @Override // x3.AbstractC0723c, java.util.List
    public final List subList(int i4, int i5) {
        e1.k.g(i4, i5, this.f6775c);
        int i6 = this.f6774b;
        return new C0722b(this.f6773a, i4 + i6, i6 + i5);
    }
}
