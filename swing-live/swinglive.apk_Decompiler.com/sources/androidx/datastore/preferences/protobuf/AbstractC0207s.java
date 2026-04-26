package androidx.datastore.preferences.protobuf;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0207s implements Cloneable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AbstractC0209u f3033a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0209u f3034b;

    public AbstractC0207s(AbstractC0209u abstractC0209u) {
        this.f3033a = abstractC0209u;
        if (abstractC0209u.g()) {
            throw new IllegalArgumentException("Default instance must be immutable.");
        }
        this.f3034b = abstractC0209u.i();
    }

    public final AbstractC0209u a() {
        AbstractC0209u abstractC0209uB = b();
        abstractC0209uB.getClass();
        if (AbstractC0209u.f(abstractC0209uB, true)) {
            return abstractC0209uB;
        }
        throw new a0();
    }

    public final AbstractC0209u b() {
        if (!this.f3034b.g()) {
            return this.f3034b;
        }
        AbstractC0209u abstractC0209u = this.f3034b;
        abstractC0209u.getClass();
        Q q4 = Q.f2927c;
        q4.getClass();
        q4.a(abstractC0209u.getClass()).d(abstractC0209u);
        abstractC0209u.h();
        return this.f3034b;
    }

    public final void c() {
        if (this.f3034b.g()) {
            return;
        }
        AbstractC0209u abstractC0209uI = this.f3033a.i();
        AbstractC0209u abstractC0209u = this.f3034b;
        Q q4 = Q.f2927c;
        q4.getClass();
        q4.a(abstractC0209uI.getClass()).b(abstractC0209uI, abstractC0209u);
        this.f3034b = abstractC0209uI;
    }

    public final Object clone() {
        AbstractC0207s abstractC0207s = (AbstractC0207s) this.f3033a.c(5);
        abstractC0207s.f3034b = b();
        return abstractC0207s;
    }
}
