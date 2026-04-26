package m;

import java.util.Iterator;

/* JADX INFO: renamed from: m.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0540b extends AbstractC0543e implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0541c f5748a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0541c f5749b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ int f5750c;

    public C0540b(C0541c c0541c, C0541c c0541c2, int i4) {
        this.f5750c = i4;
        this.f5748a = c0541c2;
        this.f5749b = c0541c;
    }

    @Override // m.AbstractC0543e
    public final void a(C0541c c0541c) {
        C0541c c0541c2;
        C0541c c0541cB = null;
        if (this.f5748a == c0541c && c0541c == this.f5749b) {
            this.f5749b = null;
            this.f5748a = null;
        }
        C0541c c0541c3 = this.f5748a;
        if (c0541c3 == c0541c) {
            switch (this.f5750c) {
                case 0:
                    c0541c2 = c0541c3.f5754d;
                    break;
                default:
                    c0541c2 = c0541c3.f5753c;
                    break;
            }
            this.f5748a = c0541c2;
        }
        C0541c c0541c4 = this.f5749b;
        if (c0541c4 == c0541c) {
            C0541c c0541c5 = this.f5748a;
            if (c0541c4 != c0541c5 && c0541c5 != null) {
                c0541cB = b(c0541c4);
            }
            this.f5749b = c0541cB;
        }
    }

    public final C0541c b(C0541c c0541c) {
        switch (this.f5750c) {
            case 0:
                return c0541c.f5753c;
            default:
                return c0541c.f5754d;
        }
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.f5749b != null;
    }

    @Override // java.util.Iterator
    public final Object next() {
        C0541c c0541c = this.f5749b;
        C0541c c0541c2 = this.f5748a;
        this.f5749b = (c0541c == c0541c2 || c0541c2 == null) ? null : b(c0541c);
        return c0541c;
    }
}
