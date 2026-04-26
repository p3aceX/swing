package l3;

import I.C0044e;
import I.Q;
import I.V;
import I.W;
import Q3.z0;
import android.content.Context;
import e1.AbstractC0367g;
import java.util.List;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public abstract class L {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ N3.d[] f5663a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final K.c f5664b;

    static {
        J3.m mVar = new J3.m(J3.b.f816a, L.class, "sharedPreferencesDataStore", "getSharedPreferencesDataStore(Landroid/content/Context;)Landroidx/datastore/core/DataStore;", 1);
        J3.s.f833a.getClass();
        f5663a = new N3.d[]{mVar};
        K.a aVar = K.a.f834a;
        X3.e eVar = Q3.O.f1596a;
        X3.d dVar = X3.d.f2437c;
        z0 z0VarC = Q3.F.c();
        dVar.getClass();
        f5664b = new K.c(aVar, Q3.F.b(AbstractC0367g.A(dVar, z0VarC)));
    }

    public static final B.k a(Context context) {
        B.k kVar;
        J3.i.e(context, "<this>");
        K.c cVar = f5664b;
        N3.d dVar = f5663a[0];
        cVar.getClass();
        J3.i.e(dVar, "property");
        B.k kVar2 = cVar.f841d;
        if (kVar2 != null) {
            return kVar2;
        }
        synchronized (cVar.f840c) {
            try {
                if (cVar.f841d == null) {
                    Context applicationContext = context.getApplicationContext();
                    I3.l lVar = cVar.f838a;
                    J3.i.d(applicationContext, "applicationContext");
                    List list = (List) lVar.invoke(applicationContext);
                    Q3.D d5 = cVar.f839b;
                    K.b bVar = new K.b(0, applicationContext, cVar);
                    J3.i.e(list, "migrations");
                    cVar.f841d = new B.k(new B.k(new Q(new W(new V(bVar, 1)), e1.k.x(new C0044e(list, null)), new p1.d(7), d5), 5), 5);
                }
                kVar = cVar.f841d;
                J3.i.b(kVar);
            } catch (Throwable th) {
                throw th;
            }
        }
        return kVar;
    }

    public static final boolean b(String str, Object obj, Set set) {
        J3.i.e(str, "key");
        return set == null ? (obj instanceof Boolean) || (obj instanceof Long) || (obj instanceof String) || (obj instanceof Double) : set.contains(str);
    }

    public static final Object c(Object obj, X.N n4) {
        if (!(obj instanceof String)) {
            return obj;
        }
        String str = (String) obj;
        if (P3.m.F0(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu")) {
            if (P3.m.F0(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!")) {
                return obj;
            }
            String strSubstring = str.substring(40);
            J3.i.d(strSubstring, "substring(...)");
            return n4.d(strSubstring);
        }
        if (!P3.m.F0(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu")) {
            return obj;
        }
        String strSubstring2 = str.substring(40);
        J3.i.d(strSubstring2, "substring(...)");
        return Double.valueOf(Double.parseDouble(strSubstring2));
    }
}
