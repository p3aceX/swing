package androidx.lifecycle;

import java.util.Iterator;
import java.util.Map;
import m.C0540b;
import m.C0544f;

/* JADX INFO: loaded from: classes.dex */
public abstract class C {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final G f3050a = new G();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final G f3051b = new G();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final G f3052c = new G();

    public static final void a(Y.g gVar) {
        Y.d dVar;
        EnumC0222h enumC0222h = gVar.i().f3077c;
        if (enumC0222h != EnumC0222h.f3068b && enumC0222h != EnumC0222h.f3069c) {
            throw new IllegalArgumentException("Failed requirement.");
        }
        Y.e eVarC = gVar.c();
        eVarC.getClass();
        Iterator it = ((C0544f) eVarC.f2460c).iterator();
        while (true) {
            C0540b c0540b = (C0540b) it;
            if (!c0540b.hasNext()) {
                dVar = null;
                break;
            }
            Map.Entry entry = (Map.Entry) c0540b.next();
            J3.i.d(entry, "components");
            String str = (String) entry.getKey();
            dVar = (Y.d) entry.getValue();
            if (J3.i.a(str, "androidx.lifecycle.internal.SavedStateHandlesProvider")) {
                break;
            }
        }
        if (dVar == null) {
            D d5 = new D(gVar.c(), (I) gVar);
            gVar.c().b("androidx.lifecycle.internal.SavedStateHandlesProvider", d5);
            gVar.i().a(new Y.a(d5, 2));
        }
    }
}
