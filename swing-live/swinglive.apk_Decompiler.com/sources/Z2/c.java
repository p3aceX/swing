package z2;

import O2.f;
import android.content.Context;
import android.net.ConnectivityManager;
import l3.C0523A;
import m1.C0553h;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public class c implements K2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0747k f6996a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0747k f6997b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public b f6998c;

    @Override // K2.a
    public final void c(C0747k c0747k) {
        f fVar = (f) c0747k.f6832c;
        this.f6996a = new C0747k(fVar, "dev.fluttercommunity.plus/connectivity", 11);
        this.f6997b = new C0747k(fVar, "dev.fluttercommunity.plus/connectivity_status", 10);
        Context context = (Context) c0747k.f6831b;
        C0523A c0523a = new C0523A((ConnectivityManager) context.getSystemService("connectivity"));
        C0553h c0553h = new C0553h(c0523a);
        this.f6998c = new b(context, c0523a);
        this.f6996a.Y(c0553h);
        this.f6997b.Z(this.f6998c);
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        this.f6996a.Y(null);
        this.f6997b.Z(null);
        this.f6998c.n();
        this.f6996a = null;
        this.f6997b = null;
        this.f6998c = null;
    }
}
