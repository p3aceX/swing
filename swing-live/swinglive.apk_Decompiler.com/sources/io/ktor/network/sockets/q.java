package io.ktor.network.sockets;

import Q3.C0152y;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0152y f4924a = new C0152y(1);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0152y f4925b = new C0152y(1);

    public q(HashMap map) {
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object a(io.ktor.utils.io.v r8, java.nio.channels.ReadableByteChannel r9, A3.c r10) {
        /*
            boolean r0 = r10 instanceof io.ktor.network.sockets.C0434f
            if (r0 == 0) goto L13
            r0 = r10
            io.ktor.network.sockets.f r0 = (io.ktor.network.sockets.C0434f) r0
            int r1 = r0.f4879c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4879c = r1
            goto L18
        L13:
            io.ktor.network.sockets.f r0 = new io.ktor.network.sockets.f
            r0.<init>(r10)
        L18:
            java.lang.Object r10 = r0.f4878b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4879c
            r3 = 1
            if (r2 == 0) goto L32
            if (r2 != r3) goto L2a
            J3.p r8 = r0.f4877a
            e1.AbstractC0367g.M(r10)
            goto L9b
        L2a:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r9 = "call to 'resume' before 'invoke' with coroutine"
            r8.<init>(r9)
            throw r8
        L32:
            e1.AbstractC0367g.M(r10)
            J3.p r10 = new J3.p
            r10.<init>()
            r0.f4877a = r10
            r0.f4879c = r3
            Z3.a r2 = r8.h()
            r2.getClass()
            Z3.f r4 = r2.h(r3)
            int r5 = r4.f2616c
            byte[] r6 = r4.f2614a
            int r7 = r6.length
            int r7 = r7 - r5
            java.nio.ByteBuffer r6 = java.nio.ByteBuffer.wrap(r6, r5, r7)
            J3.i.b(r6)
            int r9 = r9.read(r6)
            r10.f830a = r9
            int r9 = r6.position()
            int r9 = r9 - r5
            if (r9 != r3) goto L6f
            int r3 = r4.f2616c
            int r3 = r3 + r9
            r4.f2616c = r3
            long r3 = r2.f2603c
            long r5 = (long) r9
            long r3 = r3 + r5
            r2.f2603c = r3
            goto L8e
        L6f:
            if (r9 < 0) goto La3
            int r3 = r4.a()
            if (r9 > r3) goto La3
            if (r9 == 0) goto L85
            int r3 = r4.f2616c
            int r3 = r3 + r9
            r4.f2616c = r3
            long r3 = r2.f2603c
            long r5 = (long) r9
            long r3 = r3 + r5
            r2.f2603c = r3
            goto L8e
        L85:
            boolean r9 = Z3.i.b(r4)
            if (r9 == 0) goto L8e
            r2.d()
        L8e:
            java.lang.Object r8 = r8.n(r0)
            if (r8 != r1) goto L95
            goto L97
        L95:
            w3.i r8 = w3.i.f6729a
        L97:
            if (r8 != r1) goto L9a
            return r1
        L9a:
            r8 = r10
        L9b:
            int r8 = r8.f830a
            java.lang.Integer r9 = new java.lang.Integer
            r9.<init>(r8)
            return r9
        La3:
            java.lang.String r8 = "Invalid number of bytes written: "
            java.lang.String r10 = ". Should be in 0.."
            java.lang.StringBuilder r8 = com.google.crypto.tink.shaded.protobuf.S.i(r8, r9, r10)
            int r9 = r4.a()
            r8.append(r9)
            java.lang.String r8 = r8.toString()
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r8 = r8.toString()
            r9.<init>(r8)
            throw r9
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.q.a(io.ktor.utils.io.v, java.nio.channels.ReadableByteChannel, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object d(n3.e r4, io.ktor.network.sockets.u r5, io.ktor.network.sockets.F r6, A3.c r7) throws java.lang.Throwable {
        /*
            boolean r0 = r7 instanceof io.ktor.network.sockets.j
            if (r0 == 0) goto L13
            r0 = r7
            io.ktor.network.sockets.j r0 = (io.ktor.network.sockets.j) r0
            int r1 = r0.f4898d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4898d = r1
            goto L18
        L13:
            io.ktor.network.sockets.j r0 = new io.ktor.network.sockets.j
            r0.<init>(r7)
        L18:
            java.lang.Object r7 = r0.f4897c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4898d
            r3 = 1
            if (r2 == 0) goto L35
            if (r2 != r3) goto L2d
            io.ktor.network.sockets.C r4 = r0.f4896b
            java.nio.channels.SocketChannel r5 = r0.f4895a
            e1.AbstractC0367g.M(r7)     // Catch: java.lang.Throwable -> L2b
            return r4
        L2b:
            r4 = move-exception
            goto L6e
        L2d:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "call to 'resume' before 'invoke' with coroutine"
            r4.<init>(r5)
            throw r4
        L35:
            e1.AbstractC0367g.M(r7)
            java.nio.channels.spi.SelectorProvider r7 = r4.f5906a
            java.lang.String r2 = "<this>"
            J3.i.e(r7, r2)
            java.lang.String r2 = "address"
            J3.i.e(r5, r2)
            java.nio.channels.SocketChannel r7 = r7.openSocketChannel()
            J3.i.b(r7)     // Catch: java.lang.Throwable -> L6c
            io.ktor.network.sockets.v.a(r7, r6)     // Catch: java.lang.Throwable -> L6c
            J3.i.b(r7)     // Catch: java.lang.Throwable -> L6c
            r2 = 0
            r7.configureBlocking(r2)     // Catch: java.lang.Throwable -> L6c
            io.ktor.network.sockets.C r2 = new io.ktor.network.sockets.C     // Catch: java.lang.Throwable -> L6c
            r2.<init>(r7, r4, r6)     // Catch: java.lang.Throwable -> L6c
            java.net.InetSocketAddress r4 = r5.f4937c     // Catch: java.lang.Throwable -> L6c
            r0.f4895a = r7     // Catch: java.lang.Throwable -> L6c
            r0.f4896b = r2     // Catch: java.lang.Throwable -> L6c
            r0.f4898d = r3     // Catch: java.lang.Throwable -> L6c
            java.lang.Object r4 = r2.l(r4, r0)     // Catch: java.lang.Throwable -> L6c
            if (r4 != r1) goto L69
            return r1
        L69:
            return r2
        L6a:
            r5 = r7
            goto L6e
        L6c:
            r4 = move-exception
            goto L6a
        L6e:
            r5.close()
            throw r4
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.q.d(n3.e, io.ktor.network.sockets.u, io.ktor.network.sockets.F, A3.c):java.lang.Object");
    }

    public static final q e(SocketAddress socketAddress) {
        if (socketAddress instanceof InetSocketAddress) {
            return new u((InetSocketAddress) socketAddress);
        }
        if (socketAddress.getClass().getName().equals("java.net.UnixDomainSocketAddress")) {
            return new H(socketAddress);
        }
        throw new IllegalStateException("Unknown socket address type");
    }

    public void b(q qVar) {
        J3.i.e(qVar, "from");
    }

    public abstract SocketAddress c();
}
