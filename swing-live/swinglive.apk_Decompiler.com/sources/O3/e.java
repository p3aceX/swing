package O3;

import J3.i;
import e1.k;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public abstract class e extends g {
    public static List o0(c cVar) {
        i.e(cVar, "<this>");
        Iterator it = cVar.iterator();
        if (!it.hasNext()) {
            return p.f6784a;
        }
        Object next = it.next();
        if (!it.hasNext()) {
            return k.x(next);
        }
        ArrayList arrayList = new ArrayList();
        arrayList.add(next);
        while (it.hasNext()) {
            arrayList.add(it.next());
        }
        return arrayList;
    }
}
