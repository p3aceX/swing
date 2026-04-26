package io.ktor.utils.io;

import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class K implements Q3.D {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final o f4963a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final InterfaceC0767h f4964b;

    public K(o oVar, InterfaceC0767h interfaceC0767h) {
        J3.i.e(interfaceC0767h, "coroutineContext");
        this.f4963a = oVar;
        this.f4964b = interfaceC0767h;
    }

    @Override // Q3.D
    public final InterfaceC0767h n() {
        return this.f4964b;
    }
}
