package T2;

import D2.AbstractActivityC0029d;
import k.s0;
import y0.C0747k;

/* JADX INFO: renamed from: T2.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0167l implements K2.a, L2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0747k f1978a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public s0 f1979b;

    @Override // L2.a
    public final void b(Y0.n nVar) {
        e(nVar);
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        this.f1978a = c0747k;
    }

    @Override // L2.a
    public final void d() {
        s0 s0Var = this.f1979b;
        if (s0Var != null) {
            s0.n((O2.f) s0Var.f5452b, null);
            this.f1979b = null;
        }
    }

    @Override // L2.a
    public final void e(Y0.n nVar) {
        AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) nVar.f2488a;
        C0747k c0747k = this.f1978a;
        O2.f fVar = (O2.f) c0747k.f6832c;
        D2.u uVar = new D2.u(nVar, 10);
        C0166k c0166k = new C0166k();
        c0166k.f1977a = false;
        io.flutter.embedding.engine.renderer.j jVar = (io.flutter.embedding.engine.renderer.j) c0747k.f6833d;
        s0 s0Var = new s0();
        s0Var.f5451a = abstractActivityC0029d;
        s0Var.f5452b = fVar;
        s0Var.f5453c = c0166k;
        s0Var.f5454d = uVar;
        s0Var.e = jVar;
        s0Var.f5455f = new C0747k(fVar, "plugins.flutter.io/camera_android/imageStream", 10);
        s0.n(fVar, s0Var);
        this.f1979b = s0Var;
    }

    @Override // L2.a
    public final void f() {
        d();
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        this.f1978a = null;
    }
}
