package o0;

import D2.AbstractActivityC0029d;
import O2.f;
import X.N;
import Y0.n;
import android.content.Context;
import com.google.android.gms.common.internal.r;
import java.util.HashSet;
import y0.C0747k;

/* JADX INFO: renamed from: o0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0578a implements K2.a, L2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0579b f5957a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0747k f5958b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public n f5959c;

    @Override // L2.a
    public final void b(n nVar) {
        e(nVar);
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        Context context = (Context) c0747k.f6831b;
        this.f5957a = new C0579b(context);
        C0747k c0747k2 = new C0747k((f) c0747k.f6832c, "flutter.baseflow.com/permissions/methods", 11);
        this.f5958b = c0747k2;
        c0747k2.Y(new r(context, new N(24), this.f5957a, new N(25)));
    }

    @Override // L2.a
    public final void d() {
        C0579b c0579b = this.f5957a;
        if (c0579b != null) {
            c0579b.f5962c = null;
        }
        n nVar = this.f5959c;
        if (nVar != null) {
            ((HashSet) nVar.f2490c).remove(c0579b);
            n nVar2 = this.f5959c;
            ((HashSet) nVar2.f2489b).remove(this.f5957a);
        }
        this.f5959c = null;
    }

    @Override // L2.a
    public final void e(n nVar) {
        AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) nVar.f2488a;
        C0579b c0579b = this.f5957a;
        if (c0579b != null) {
            c0579b.f5962c = abstractActivityC0029d;
        }
        this.f5959c = nVar;
        ((HashSet) nVar.f2490c).add(c0579b);
        n nVar2 = this.f5959c;
        ((HashSet) nVar2.f2489b).add(this.f5957a);
    }

    @Override // L2.a
    public final void f() {
        d();
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        this.f5958b.Y(null);
        this.f5958b = null;
    }
}
