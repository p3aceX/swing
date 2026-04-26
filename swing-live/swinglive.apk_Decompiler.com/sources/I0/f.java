package i0;

import androidx.window.extensions.layout.WindowLayoutComponent;
import k0.C0509a;

/* JADX INFO: loaded from: classes.dex */
public final class f extends J3.j implements I3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final f f4473a = new f(0);

    @Override // I3.a
    public final Object a() {
        WindowLayoutComponent windowLayoutComponentA;
        int i4 = 21;
        try {
            ClassLoader classLoader = h.class.getClassLoader();
            e eVar = classLoader != null ? new e(classLoader, new B.k(classLoader, i4)) : null;
            if (eVar != null && (windowLayoutComponentA = eVar.a()) != null) {
                J3.i.d(classLoader, "loader");
                B.k kVar = new B.k(classLoader, i4);
                int iA = f0.e.a();
                return iA >= 2 ? new k0.d(windowLayoutComponentA) : iA == 1 ? new k0.c(windowLayoutComponentA, kVar) : new C0509a();
            }
        } catch (Throwable unused) {
            g gVar = g.f4474a;
        }
        return null;
    }
}
