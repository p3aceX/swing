package io.ktor.network.sockets;

import java.nio.channels.SelectableChannel;
import java.nio.channels.SocketChannel;

/* JADX INFO: loaded from: classes.dex */
public final class C extends w implements y {

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final SocketChannel f4838s;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C(SocketChannel socketChannel, n3.e eVar, F f4) {
        super(socketChannel, eVar, null, f4);
        J3.i.e(eVar, "selector");
        this.f4838s = socketChannel;
        if (socketChannel.isBlocking()) {
            throw new IllegalArgumentException("Channel need to be configured as non-blocking.");
        }
    }

    /* JADX WARN: Code restructure failed: missing block: B:77:0x00f5, code lost:
    
        d(n3.p.f5929m, false);
     */
    /* JADX WARN: Code restructure failed: missing block: B:78:0x00fa, code lost:
    
        return r12;
     */
    /* JADX WARN: Code restructure failed: missing block: B:80:0x0102, code lost:
    
        throw new java.lang.IllegalStateException("localAddress and remoteAddress should not be null.");
     */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object l(java.net.SocketAddress r13, A3.c r14) throws java.io.IOException {
        /*
            Method dump skipped, instruction units count: 276
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.C.l(java.net.SocketAddress, A3.c):java.lang.Object");
    }

    @Override // n3.q
    public final SelectableChannel r() {
        return this.f4838s;
    }
}
