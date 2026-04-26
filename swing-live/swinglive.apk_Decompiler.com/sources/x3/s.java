package x3;

import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public abstract class s extends AbstractC0367g {
    public static int c0(int i4) {
        return i4 < 0 ? i4 : i4 < 3 ? i4 + 1 : i4 < 1073741824 ? (int) ((i4 / 0.75f) + 1.0f) : com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
    }

    public static Map d0(w3.c... cVarArr) {
        if (cVarArr.length <= 0) {
            return q.f6785a;
        }
        LinkedHashMap linkedHashMap = new LinkedHashMap(c0(cVarArr.length));
        e0(linkedHashMap, cVarArr);
        return linkedHashMap;
    }

    public static final void e0(LinkedHashMap linkedHashMap, w3.c[] cVarArr) {
        for (w3.c cVar : cVarArr) {
            linkedHashMap.put(cVar.f6718a, cVar.f6719b);
        }
    }

    public static Map f0(ArrayList arrayList) {
        q qVar = q.f6785a;
        int size = arrayList.size();
        if (size == 0) {
            return qVar;
        }
        if (size == 1) {
            w3.c cVar = (w3.c) arrayList.get(0);
            J3.i.e(cVar, "pair");
            Map mapSingletonMap = Collections.singletonMap(cVar.f6718a, cVar.f6719b);
            J3.i.d(mapSingletonMap, "singletonMap(...)");
            return mapSingletonMap;
        }
        LinkedHashMap linkedHashMap = new LinkedHashMap(c0(arrayList.size()));
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            w3.c cVar2 = (w3.c) it.next();
            linkedHashMap.put(cVar2.f6718a, cVar2.f6719b);
        }
        return linkedHashMap;
    }
}
