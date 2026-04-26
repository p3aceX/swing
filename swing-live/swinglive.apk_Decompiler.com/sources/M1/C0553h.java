package m1;

import D2.v;
import O2.m;
import android.net.ConnectivityManager;
import l3.C0523A;
import o.AbstractFutureC0576h;
import o.C0571c;

/* JADX INFO: renamed from: m1.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0553h implements m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f5788a;

    public /* synthetic */ C0553h(Object obj) {
        this.f5788a = obj;
    }

    public void a(String str) {
        J3.i.e(str, "reason");
        y2.g gVar = (y2.g) this.f5788a;
        gVar.f6893k.set(false);
        gVar.f6897o.set(0L);
        gVar.f6887d.invoke(str);
    }

    public void b(Exception exc) {
        j jVar = (j) this.f5788a;
        jVar.getClass();
        if (AbstractFutureC0576h.f5952f.e(jVar, null, new C0571c(exc))) {
            AbstractFutureC0576h.c(jVar);
        }
    }

    @Override // O2.m
    public void g(v vVar, N2.j jVar) {
        if (!"check".equals((String) vVar.f260b)) {
            jVar.b();
        } else {
            ConnectivityManager connectivityManager = (ConnectivityManager) ((C0523A) this.f5788a).f5626a;
            jVar.c(C0523A.c(connectivityManager.getNetworkCapabilities(connectivityManager.getActiveNetwork())));
        }
    }

    public C0553h(C1.a aVar, String str, int i4, long j4) {
        C1.b hVar;
        J3.i.e(aVar, "type");
        J3.i.e(str, "host");
        C1.c cVar = C1.c.f126a;
        int iOrdinal = aVar.ordinal();
        if (iOrdinal == 0) {
            hVar = new E1.h(str, i4, cVar);
        } else {
            if (iOrdinal != 1) {
                throw new A0.b();
            }
            hVar = new D1.c(str, i4, cVar);
        }
        hVar.f125a = j4;
        this.f5788a = hVar;
    }
}
