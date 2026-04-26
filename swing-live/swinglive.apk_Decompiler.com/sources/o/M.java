package O;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashSet;

/* JADX INFO: loaded from: classes.dex */
public final class M implements K {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ N f1222a;

    public M(N n4) {
        this.f1222a = n4;
    }

    @Override // O.K
    public final boolean a(ArrayList arrayList, ArrayList arrayList2) {
        N n4 = this.f1222a;
        ArrayList arrayList3 = n4.f1240d;
        C0090a c0090a = (C0090a) arrayList3.get(arrayList3.size() - 1);
        n4.f1243h = c0090a;
        Iterator it = c0090a.f1304a.iterator();
        while (it.hasNext()) {
            AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = ((V) it.next()).f1292b;
            if (abstractComponentCallbacksC0109u != null) {
                abstractComponentCallbacksC0109u.f1419s = true;
            }
        }
        boolean zR = n4.R(arrayList, arrayList2, -1, 0);
        if (!n4.f1248m.isEmpty() && arrayList.size() > 0) {
            ((Boolean) arrayList2.get(arrayList.size() - 1)).getClass();
            LinkedHashSet linkedHashSet = new LinkedHashSet();
            Iterator it2 = arrayList.iterator();
            while (it2.hasNext()) {
                linkedHashSet.addAll(N.E((C0090a) it2.next()));
            }
            Iterator it3 = n4.f1248m.iterator();
            while (it3.hasNext()) {
                if (it3.next() != null) {
                    throw new ClassCastException();
                }
                Iterator it4 = linkedHashSet.iterator();
                if (it4.hasNext()) {
                    throw null;
                }
            }
        }
        return zR;
    }
}
