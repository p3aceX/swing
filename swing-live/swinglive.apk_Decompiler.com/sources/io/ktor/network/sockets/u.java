package io.ktor.network.sockets;

import java.net.InetSocketAddress;
import java.net.SocketAddress;

/* JADX INFO: loaded from: classes.dex */
public final class u extends q {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final InetSocketAddress f4937c;

    public u(InetSocketAddress inetSocketAddress) {
        this.f4937c = inetSocketAddress;
    }

    @Override // io.ktor.network.sockets.q
    public final SocketAddress c() {
        return this.f4937c;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!u.class.equals(obj != null ? obj.getClass() : null)) {
            return false;
        }
        J3.i.c(obj, "null cannot be cast to non-null type io.ktor.network.sockets.InetSocketAddress");
        return J3.i.a(this.f4937c, ((u) obj).f4937c);
    }

    public final int hashCode() {
        return this.f4937c.hashCode();
    }

    public final String toString() {
        String string = this.f4937c.toString();
        J3.i.d(string, "toString(...)");
        return string;
    }

    public u(String str, int i4) {
        J3.i.e(str, "hostname");
        this.f4937c = new InetSocketAddress(str, i4);
    }
}
