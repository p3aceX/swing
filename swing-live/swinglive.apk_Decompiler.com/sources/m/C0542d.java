package m;

import java.util.Iterator;

/* JADX INFO: renamed from: m.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0542d extends AbstractC0543e implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0541c f5755a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f5756b = true;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0544f f5757c;

    public C0542d(C0544f c0544f) {
        this.f5757c = c0544f;
    }

    @Override // m.AbstractC0543e
    public final void a(C0541c c0541c) {
        C0541c c0541c2 = this.f5755a;
        if (c0541c == c0541c2) {
            C0541c c0541c3 = c0541c2.f5754d;
            this.f5755a = c0541c3;
            this.f5756b = c0541c3 == null;
        }
    }

    @Override // java.util.Iterator
    public final boolean hasNext() {
        if (this.f5756b) {
            return this.f5757c.f5758a != null;
        }
        C0541c c0541c = this.f5755a;
        return (c0541c == null || c0541c.f5753c == null) ? false : true;
    }

    @Override // java.util.Iterator
    public final Object next() {
        if (this.f5756b) {
            this.f5756b = false;
            this.f5755a = this.f5757c.f5758a;
        } else {
            C0541c c0541c = this.f5755a;
            this.f5755a = c0541c != null ? c0541c.f5753c : null;
        }
        return this.f5755a;
    }
}
