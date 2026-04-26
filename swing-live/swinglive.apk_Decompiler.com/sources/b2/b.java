package B2;

import D2.AbstractActivityC0029d;
import J3.i;
import Y0.n;
import defpackage.e;
import defpackage.f;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class b implements K2.a, f, L2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0779j f118a;

    public final void a(defpackage.b bVar) throws a {
        C0779j c0779j = this.f118a;
        i.b(c0779j);
        AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) c0779j.f6969b;
        if (abstractActivityC0029d == null) {
            throw new a();
        }
        i.b(abstractActivityC0029d);
        boolean z4 = (abstractActivityC0029d.getWindow().getAttributes().flags & 128) != 0;
        Boolean bool = bVar.f3203a;
        i.b(bool);
        if (bool.booleanValue()) {
            if (z4) {
                return;
            }
            abstractActivityC0029d.getWindow().addFlags(128);
        } else if (z4) {
            abstractActivityC0029d.getWindow().clearFlags(128);
        }
    }

    @Override // L2.a
    public final void b(n nVar) {
        i.e(nVar, "binding");
        e(nVar);
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        i.e(c0747k, "flutterPluginBinding");
        O2.f fVar = (O2.f) c0747k.f6832c;
        i.d(fVar, "getBinaryMessenger(...)");
        e.a(f.f4243i, fVar, this);
        this.f118a = new C0779j(1);
    }

    @Override // L2.a
    public final void d() {
        C0779j c0779j = this.f118a;
        if (c0779j != null) {
            c0779j.f6969b = null;
        }
    }

    @Override // L2.a
    public final void e(n nVar) {
        i.e(nVar, "binding");
        C0779j c0779j = this.f118a;
        if (c0779j != null) {
            c0779j.f6969b = (AbstractActivityC0029d) nVar.f2488a;
        }
    }

    @Override // L2.a
    public final void f() {
        d();
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        i.e(c0747k, "binding");
        O2.f fVar = (O2.f) c0747k.f6832c;
        i.d(fVar, "getBinaryMessenger(...)");
        e.a(f.f4243i, fVar, null);
        this.f118a = null;
    }
}
