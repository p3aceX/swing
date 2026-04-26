package io.ktor.utils.io;

import Q3.C0141m;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: io.ktor.utils.io.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0440d implements InterfaceC0441e {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0141m f4972b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Throwable f4973c;

    public C0440d(C0141m c0141m) {
        this.f4972b = c0141m;
        String property = System.getProperty("io.ktor.development");
        if (property == null || !Boolean.parseBoolean(property)) {
            return;
        }
        int iHashCode = c0141m.hashCode();
        H0.a.c(16);
        String string = Integer.toString(iHashCode, 16);
        J3.i.d(string, "toString(...)");
        Throwable th = new Throwable("ReadTask 0x".concat(string));
        e1.k.D(th);
        this.f4973c = th;
    }

    @Override // io.ktor.utils.io.InterfaceC0441e
    public final Throwable c() {
        return this.f4973c;
    }

    @Override // io.ktor.utils.io.InterfaceC0441e
    public final InterfaceC0762c d() {
        return this.f4972b;
    }
}
