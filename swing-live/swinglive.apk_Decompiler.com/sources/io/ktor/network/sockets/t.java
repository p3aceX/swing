package io.ktor.network.sockets;

import Q3.O;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.DatagramChannel;
import java.nio.channels.SelectableChannel;
import v3.C0695a;

/* JADX INFO: loaded from: classes.dex */
public final class t extends w implements InterfaceC0429a, k {

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final DatagramChannel f4934s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final p f4935t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public final S3.t f4936u;

    public t(DatagramChannel datagramChannel, n3.e eVar) {
        super(datagramChannel, eVar, io.ktor.network.util.a.f4945b, null);
        this.f4934s = datagramChannel;
        this.f4935t = new p(datagramChannel, this);
        X3.e eVar2 = O.f1596a;
        this.f4936u = S3.m.c(this, X3.d.f2437c, new s(this, null));
    }

    public static final Object l(t tVar, s sVar) {
        tVar.getClass();
        C0695a c0695a = io.ktor.network.util.a.f4945b;
        ByteBuffer byteBuffer = (ByteBuffer) c0695a.a();
        try {
            SocketAddress socketAddressReceive = tVar.f4934s.receive(byteBuffer);
            if (socketAddressReceive == null) {
                return tVar.o(byteBuffer, sVar);
            }
            tVar.d(n3.p.e, false);
            byteBuffer.flip();
            Z3.a aVar = new Z3.a();
            Z3.i.g(aVar, byteBuffer);
            l lVar = new l(aVar, q.e(socketAddressReceive));
            c0695a.d(byteBuffer);
            return lVar;
        } catch (Throwable th) {
            io.ktor.network.util.a.f4945b.d(byteBuffer);
            throw th;
        }
    }

    @Override // io.ktor.network.sockets.A, n3.r, java.io.Closeable, java.lang.AutoCloseable
    public final void close() {
        this.f4936u.a(null);
        super.close();
        this.f4935t.j(null);
    }

    /* JADX WARN: Removed duplicated region for block: B:17:0x004c A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:21:0x0056  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:16:0x004a -> B:26:0x004d). Please report as a decompilation issue!!! */
    /*  JADX ERROR: JadxOverflowException in pass: RegionMakerVisitor
        jadx.core.utils.exceptions.JadxOverflowException: Regions count limit reached
        	at jadx.core.utils.ErrorsCounter.addError(ErrorsCounter.java:59)
        	at jadx.core.utils.ErrorsCounter.error(ErrorsCounter.java:31)
        	at jadx.core.dex.attributes.nodes.NotificationAttrNode.addError(NotificationAttrNode.java:19)
        */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object o(java.nio.ByteBuffer r6, A3.c r7) {
        /*
            r5 = this;
            boolean r0 = r7 instanceof io.ktor.network.sockets.r
            if (r0 == 0) goto L13
            r0 = r7
            io.ktor.network.sockets.r r0 = (io.ktor.network.sockets.r) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.e = r1
            goto L18
        L13:
            io.ktor.network.sockets.r r0 = new io.ktor.network.sockets.r
            r0.<init>(r5, r7)
        L18:
            java.lang.Object r7 = r0.f4928c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            r3 = 1
            if (r2 == 0) goto L34
            if (r2 != r3) goto L2c
            io.ktor.network.sockets.t r6 = r0.f4927b
            java.nio.ByteBuffer r2 = r0.f4926a
            e1.AbstractC0367g.M(r7)
            r7 = r2
            goto L4d
        L2c:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L34:
            e1.AbstractC0367g.M(r7)
            r7 = r6
            r6 = r5
        L39:
            n3.p r2 = n3.p.e
            r6.d(r2, r3)
            r0.f4926a = r7
            r0.f4927b = r6
            r0.e = r3
            n3.e r4 = r6.f4939p
            java.lang.Object r2 = r4.p(r6, r2, r0)
            if (r2 != r1) goto L4d
            return r1
        L4d:
            java.nio.channels.DatagramChannel r2 = r6.f4934s     // Catch: java.lang.Throwable -> L76
            java.net.SocketAddress r2 = r2.receive(r7)     // Catch: java.lang.Throwable -> L76
            if (r2 != 0) goto L56
            goto L39
        L56:
            n3.p r0 = n3.p.e
            r1 = 0
            r6.d(r0, r1)
            r7.flip()
            Z3.a r6 = new Z3.a
            r6.<init>()
            Z3.i.g(r6, r7)
            io.ktor.network.sockets.q r0 = io.ktor.network.sockets.q.e(r2)
            io.ktor.network.sockets.l r1 = new io.ktor.network.sockets.l
            r1.<init>(r6, r0)
            v3.a r6 = io.ktor.network.util.a.f4945b
            r6.d(r7)
            return r1
        L76:
            r6 = move-exception
            v3.a r0 = io.ktor.network.util.a.f4945b
            r0.d(r7)
            throw r6
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.t.o(java.nio.ByteBuffer, A3.c):java.lang.Object");
    }

    @Override // n3.q
    public final SelectableChannel r() {
        return this.f4934s;
    }
}
