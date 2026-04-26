package com.google.crypto.tink.shaded.protobuf;

import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class G extends H {
    @Override // com.google.crypto.tink.shaded.protobuf.H
    public final void a(Object obj, long j4) {
        ((AbstractC0297b) ((InterfaceC0319y) o0.f3823c.i(obj, j4))).f3772a = false;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.H
    public final void b(Object obj, long j4, Object obj2) {
        n0 n0Var = o0.f3823c;
        InterfaceC0319y interfaceC0319yC = (InterfaceC0319y) n0Var.i(obj, j4);
        InterfaceC0319y interfaceC0319y = (InterfaceC0319y) n0Var.i(obj2, j4);
        int size = interfaceC0319yC.size();
        int size2 = interfaceC0319y.size();
        if (size > 0 && size2 > 0) {
            if (!((AbstractC0297b) interfaceC0319yC).f3772a) {
                interfaceC0319yC = interfaceC0319yC.c(size2 + size);
            }
            interfaceC0319yC.addAll(interfaceC0319y);
        }
        if (size > 0) {
            interfaceC0319y = interfaceC0319yC;
        }
        o0.p(obj, j4, interfaceC0319y);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.H
    public final List c(Object obj, long j4) {
        InterfaceC0319y interfaceC0319y = (InterfaceC0319y) o0.f3823c.i(obj, j4);
        if (((AbstractC0297b) interfaceC0319y).f3772a) {
            return interfaceC0319y;
        }
        int size = interfaceC0319y.size();
        InterfaceC0319y interfaceC0319yC = interfaceC0319y.c(size == 0 ? 10 : size * 2);
        o0.p(obj, j4, interfaceC0319yC);
        return interfaceC0319yC;
    }
}
