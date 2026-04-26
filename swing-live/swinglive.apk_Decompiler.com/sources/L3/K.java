package l3;

import android.content.Context;
import android.util.Log;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import x3.AbstractC0728h;
import y0.C0747k;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class K implements K2.a, InterfaceC0529f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Context f5660a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0747k f5661b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final X.N f5662c = new X.N(22);

    public static final Object r(K k4, String str, String str2, A3.j jVar) {
        k4.getClass();
        L.d dVar = new L.d(str);
        Context context = k4.f5660a;
        if (context != null) {
            Object objM = L.a(context).m(new L.h(new C0533j(dVar, str2, null), null), jVar);
            return objM == EnumC0789a.f6999a ? objM : w3.i.f6729a;
        }
        J3.i.g("context");
        throw null;
    }

    /* JADX WARN: Code restructure failed: missing block: B:34:0x00ca, code lost:
    
        if (r13 == r1) goto L35;
     */
    /* JADX WARN: Removed duplicated region for block: B:31:0x009b  */
    /* JADX WARN: Removed duplicated region for block: B:43:0x00e7 A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0016  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:34:0x00ca -> B:36:0x00cd). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object s(l3.K r11, java.util.List r12, A3.c r13) {
        /*
            Method dump skipped, instruction units count: 237
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: l3.K.s(l3.K, java.util.List, A3.c):java.lang.Object");
    }

    @Override // l3.InterfaceC0529f
    public final void a(String str, String str2, C0530g c0530g) throws Throwable {
        Q3.F.w(new J(this, str, str2, null));
    }

    @Override // l3.InterfaceC0529f
    public final void b(String str, long j4, C0530g c0530g) throws Throwable {
        Q3.F.w(new I(str, this, j4, null));
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        J3.i.e(c0747k, "binding");
        O2.f fVar = (O2.f) c0747k.f6832c;
        J3.i.d(fVar, "getBinaryMessenger(...)");
        Context context = (Context) c0747k.f6831b;
        J3.i.d(context, "getApplicationContext(...)");
        this.f5660a = context;
        try {
            InterfaceC0529f.f5681l.getClass();
            C0528e.b(fVar, this, "data_store");
            this.f5661b = new C0747k(fVar, context, this.f5662c);
        } catch (Exception e) {
            Log.e("SharedPreferencesPlugin", "Received exception while setting up SharedPreferencesPlugin", e);
        }
        new C0524a().c(c0747k);
    }

    @Override // l3.InterfaceC0529f
    public final void d(String str, List list, C0530g c0530g) throws Throwable {
        Q3.F.w(new D(this, str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu".concat(this.f5662c.e(list)), null));
    }

    @Override // l3.InterfaceC0529f
    public final String e(String str, C0530g c0530g) throws Throwable {
        J3.r rVar = new J3.r();
        Q3.F.w(new x(str, this, rVar, null));
        return (String) rVar.f832a;
    }

    @Override // l3.InterfaceC0529f
    public final Boolean f(String str, C0530g c0530g) throws Throwable {
        J3.r rVar = new J3.r();
        Q3.F.w(new C0538o(str, this, rVar, null));
        return (Boolean) rVar.f832a;
    }

    @Override // l3.InterfaceC0529f
    public final List g(List list, C0530g c0530g) {
        return AbstractC0728h.i0(((Map) Q3.F.w(new u(this, list, null))).keySet());
    }

    @Override // l3.InterfaceC0529f
    public final O h(String str, C0530g c0530g) throws Throwable {
        String strE = e(str, c0530g);
        if (strE != null) {
            return P3.m.F0(strE, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!") ? new O(strE, M.f5667d) : P3.m.F0(strE, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu") ? new O(null, M.f5666c) : new O(null, M.e);
        }
        return null;
    }

    @Override // l3.InterfaceC0529f
    public final Map i(List list, C0530g c0530g) {
        return (Map) Q3.F.w(new C0534k(this, list, null));
    }

    @Override // l3.InterfaceC0529f
    public final Long j(String str, C0530g c0530g) throws Throwable {
        J3.r rVar = new J3.r();
        Q3.F.w(new t(str, this, rVar, null));
        return (Long) rVar.f832a;
    }

    @Override // l3.InterfaceC0529f
    public final ArrayList k(String str, C0530g c0530g) throws Throwable {
        List list;
        String strE = e(str, c0530g);
        if (strE == null || P3.m.F0(strE, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!") || !P3.m.F0(strE, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu") || (list = (List) L.c(strE, this.f5662c)) == null) {
            return null;
        }
        ArrayList arrayList = new ArrayList();
        for (Object obj : list) {
            if (obj instanceof String) {
                arrayList.add(obj);
            }
        }
        return arrayList;
    }

    @Override // l3.InterfaceC0529f
    public final Double l(String str, C0530g c0530g) throws Throwable {
        J3.r rVar = new J3.r();
        Q3.F.w(new r(str, this, rVar, null));
        return (Double) rVar.f832a;
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        J3.i.e(c0747k, "binding");
        O2.f fVar = (O2.f) c0747k.f6832c;
        J3.i.d(fVar, "getBinaryMessenger(...)");
        InterfaceC0529f.f5681l.getClass();
        C0528e.b(fVar, null, "data_store");
        C0747k c0747k2 = this.f5661b;
        if (c0747k2 != null) {
            C0528e.b((O2.f) c0747k2.f6831b, null, "shared_preferences");
        }
        this.f5661b = null;
    }

    @Override // l3.InterfaceC0529f
    public final void n(String str, boolean z4, C0530g c0530g) throws Throwable {
        Q3.F.w(new C(str, this, z4, null));
    }

    @Override // l3.InterfaceC0529f
    public final void o(String str, double d5, C0530g c0530g) throws Throwable {
        Q3.F.w(new F(str, this, d5, null));
    }

    @Override // l3.InterfaceC0529f
    public final void p(String str, String str2, C0530g c0530g) throws Throwable {
        Q3.F.w(new G(this, str, str2, null));
    }

    @Override // l3.InterfaceC0529f
    public final void q(List list, C0530g c0530g) throws Throwable {
        Q3.F.w(new C0532i(this, list, null));
    }
}
