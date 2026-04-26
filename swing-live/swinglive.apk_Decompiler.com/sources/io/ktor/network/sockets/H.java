package io.ktor.network.sockets;

import java.net.SocketAddress;

/* JADX INFO: loaded from: classes.dex */
public final class H extends q {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final SocketAddress f4843c;

    static {
        try {
            Class.forName("java.net.UnixDomainSocketAddress");
        } catch (ClassNotFoundException unused) {
        }
    }

    public H(SocketAddress socketAddress) {
        this.f4843c = socketAddress;
        if (!socketAddress.getClass().getName().equals("java.net.UnixDomainSocketAddress")) {
            throw new IllegalStateException("address should be java.net.UnixDomainSocketAddress");
        }
    }

    @Override // io.ktor.network.sockets.q
    public final SocketAddress c() {
        return this.f4843c;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!H.class.equals(obj != null ? obj.getClass() : null)) {
            return false;
        }
        J3.i.c(obj, "null cannot be cast to non-null type io.ktor.network.sockets.UnixSocketAddress");
        return J3.i.a(this.f4843c, ((H) obj).f4843c);
    }

    public final int hashCode() {
        return this.f4843c.hashCode();
    }

    public final String toString() {
        return this.f4843c.toString();
    }
}
