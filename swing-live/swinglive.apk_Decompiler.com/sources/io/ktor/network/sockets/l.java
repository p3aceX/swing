package io.ktor.network.sockets;

import u3.AbstractC0692a;

/* JADX INFO: loaded from: classes.dex */
public final class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Z3.a f4899a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final q f4900b;

    public l(Z3.a aVar, q qVar) {
        J3.i.e(qVar, "address");
        this.f4899a = aVar;
        this.f4900b = qVar;
        if (AbstractC0692a.a(aVar) <= 65535) {
            return;
        }
        throw new IllegalArgumentException(("Datagram size limit exceeded: " + AbstractC0692a.a(aVar) + " of possible 65535").toString());
    }
}
