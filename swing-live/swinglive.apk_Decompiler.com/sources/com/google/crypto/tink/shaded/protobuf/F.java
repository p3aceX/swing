package com.google.crypto.tink.shaded.protobuf;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class F extends H {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Class f3735c = Collections.unmodifiableList(Collections.EMPTY_LIST).getClass();

    public static List d(Object obj, int i4, long j4) {
        List list = (List) o0.f3823c.i(obj, j4);
        if (list.isEmpty()) {
            List d5 = list instanceof E ? new D(i4) : ((list instanceof Y) && (list instanceof InterfaceC0319y)) ? ((InterfaceC0319y) list).c(i4) : new ArrayList(i4);
            o0.p(obj, j4, d5);
            return d5;
        }
        if (f3735c.isAssignableFrom(list.getClass())) {
            ArrayList arrayList = new ArrayList(list.size() + i4);
            arrayList.addAll(list);
            o0.p(obj, j4, arrayList);
            return arrayList;
        }
        if (list instanceof j0) {
            D d6 = new D(list.size() + i4);
            d6.addAll((j0) list);
            o0.p(obj, j4, d6);
            return d6;
        }
        if ((list instanceof Y) && (list instanceof InterfaceC0319y)) {
            InterfaceC0319y interfaceC0319y = (InterfaceC0319y) list;
            if (!((AbstractC0297b) interfaceC0319y).f3772a) {
                InterfaceC0319y interfaceC0319yC = interfaceC0319y.c(list.size() + i4);
                o0.p(obj, j4, interfaceC0319yC);
                return interfaceC0319yC;
            }
        }
        return list;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.H
    public final void a(Object obj, long j4) {
        Object objUnmodifiableList;
        List list = (List) o0.f3823c.i(obj, j4);
        if (list instanceof E) {
            objUnmodifiableList = ((E) list).a();
        } else {
            if (f3735c.isAssignableFrom(list.getClass())) {
                return;
            }
            if ((list instanceof Y) && (list instanceof InterfaceC0319y)) {
                AbstractC0297b abstractC0297b = (AbstractC0297b) ((InterfaceC0319y) list);
                if (abstractC0297b.f3772a) {
                    abstractC0297b.f3772a = false;
                    return;
                }
                return;
            }
            objUnmodifiableList = Collections.unmodifiableList(list);
        }
        o0.p(obj, j4, objUnmodifiableList);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.H
    public final void b(Object obj, long j4, Object obj2) {
        List list = (List) o0.f3823c.i(obj2, j4);
        List listD = d(obj, list.size(), j4);
        int size = listD.size();
        int size2 = list.size();
        if (size > 0 && size2 > 0) {
            listD.addAll(list);
        }
        if (size > 0) {
            list = listD;
        }
        o0.p(obj, j4, list);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.H
    public final List c(Object obj, long j4) {
        return d(obj, 10, j4);
    }
}
