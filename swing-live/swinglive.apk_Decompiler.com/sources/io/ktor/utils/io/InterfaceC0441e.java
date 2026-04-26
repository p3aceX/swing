package io.ktor.utils.io;

import e1.AbstractC0367g;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: io.ktor.utils.io.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public interface InterfaceC0441e extends InterfaceC0443g {
    default void a() {
        InterfaceC0762c interfaceC0762cD = d();
        InterfaceC0443g.f4976a.getClass();
        interfaceC0762cD.resumeWith(w3.i.f6729a);
    }

    default void b(Throwable th) {
        Object objH;
        InterfaceC0762c interfaceC0762cD = d();
        if (th != null) {
            objH = AbstractC0367g.h(th);
        } else {
            InterfaceC0443g.f4976a.getClass();
            objH = w3.i.f6729a;
        }
        interfaceC0762cD.resumeWith(objH);
    }

    Throwable c();

    InterfaceC0762c d();
}
