package j3;

import D2.AbstractActivityC0029d;
import X.N;
import Y0.n;
import android.content.Context;
import java.util.HashSet;
import y0.C0747k;

/* JADX INFO: renamed from: j3.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0467d implements K2.a, L2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0466c f5233a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public O2.f f5234b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public n f5235c;

    @Override // L2.a
    public final void b(n nVar) {
        this.f5235c = nVar;
        ((HashSet) nVar.f2490c).add(this.f5233a);
        this.f5233a.f5230b = (AbstractActivityC0029d) nVar.f2488a;
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        O2.f fVar = (O2.f) c0747k.f6832c;
        N n4 = new N(19);
        this.f5234b = fVar;
        C0466c c0466c = new C0466c((Context) c0747k.f6831b, n4);
        this.f5233a = c0466c;
        C0466c.i(fVar, c0466c);
    }

    @Override // L2.a
    public final void d() {
        n nVar = this.f5235c;
        ((HashSet) nVar.f2490c).remove(this.f5233a);
        this.f5233a.f5230b = null;
        this.f5235c = null;
    }

    @Override // L2.a
    public final void e(n nVar) {
        this.f5235c = nVar;
        ((HashSet) nVar.f2490c).add(this.f5233a);
        this.f5233a.f5230b = (AbstractActivityC0029d) nVar.f2488a;
    }

    @Override // L2.a
    public final void f() {
        n nVar = this.f5235c;
        ((HashSet) nVar.f2490c).remove(this.f5233a);
        this.f5233a.f5230b = null;
        this.f5235c = null;
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        this.f5233a = null;
        O2.f fVar = this.f5234b;
        if (fVar != null) {
            C0466c.i(fVar, null);
            this.f5234b = null;
        }
    }
}
