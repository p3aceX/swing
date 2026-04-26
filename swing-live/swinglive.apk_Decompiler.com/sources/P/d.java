package P;

import J3.i;
import O.AbstractComponentCallbacksC0109u;
import O.N;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final c f1475a = c.f1474a;

    public static c a(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        while (abstractComponentCallbacksC0109u != null) {
            if (abstractComponentCallbacksC0109u.f1425z != null && abstractComponentCallbacksC0109u.f1417q) {
                abstractComponentCallbacksC0109u.o();
            }
            abstractComponentCallbacksC0109u = abstractComponentCallbacksC0109u.f1387B;
        }
        return f1475a;
    }

    public static void b(a aVar) {
        if (N.J(3)) {
            Log.d("FragmentManager", "StrictMode violation in ".concat(aVar.f1469a.getClass().getName()), aVar);
        }
    }

    public static final void c(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u, String str) {
        i.e(str, "previousFragmentId");
        b(new a(abstractComponentCallbacksC0109u, "Attempting to reuse fragment " + abstractComponentCallbacksC0109u + " with previous ID " + str));
        a(abstractComponentCallbacksC0109u).getClass();
    }
}
