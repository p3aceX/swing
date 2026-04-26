package com.google.crypto.tink.shaded.protobuf;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class M {
    public static void a(Object obj, Object obj2) {
        L l2 = (L) obj;
        if (obj2 != null) {
            throw new ClassCastException();
        }
        if (l2.isEmpty()) {
            return;
        }
        Iterator it = l2.entrySet().iterator();
        if (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            entry.getKey();
            entry.getValue();
            throw null;
        }
    }

    public static L b(Object obj, Object obj2) {
        L lC = (L) obj;
        L l2 = (L) obj2;
        if (!l2.isEmpty()) {
            if (!lC.f3742a) {
                lC = lC.c();
            }
            lC.b();
            if (!l2.isEmpty()) {
                lC.putAll(l2);
            }
        }
        return lC;
    }
}
