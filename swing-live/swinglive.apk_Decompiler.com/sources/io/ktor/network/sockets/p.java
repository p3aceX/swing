package io.ktor.network.sockets;

import Q3.C0152y;
import java.nio.channels.DatagramChannel;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class p implements S3.w {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f4920d = AtomicReferenceFieldUpdater.newUpdater(p.class, Object.class, "onCloseHandler");
    public static final /* synthetic */ AtomicIntegerFieldUpdater e = AtomicIntegerFieldUpdater.newUpdater(p.class, "closed");

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final DatagramChannel f4921a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final t f4922b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Y3.d f4923c;
    private volatile /* synthetic */ int closed;
    private volatile /* synthetic */ Object closedCause;
    private volatile /* synthetic */ Object onCloseHandler;

    public p(DatagramChannel datagramChannel, t tVar) {
        J3.i.e(tVar, "socket");
        this.f4921a = datagramChannel;
        this.f4922b = tVar;
        this.onCloseHandler = null;
        this.closed = 0;
        this.closedCause = null;
        this.f4923c = new Y3.d();
    }

    /* JADX WARN: Removed duplicated region for block: B:17:0x0051 A[RETURN] */
    /* JADX WARN: Removed duplicated region for block: B:20:0x0063  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0016  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:16:0x004f -> B:18:0x0052). Please report as a decompilation issue!!! */
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
    public static final java.lang.Object a(io.ktor.network.sockets.p r6, java.nio.ByteBuffer r7, io.ktor.network.sockets.q r8, A3.c r9) {
        /*
            r6.getClass()
            boolean r0 = r9 instanceof io.ktor.network.sockets.o
            if (r0 == 0) goto L16
            r0 = r9
            io.ktor.network.sockets.o r0 = (io.ktor.network.sockets.o) r0
            int r1 = r0.e
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L16
            int r1 = r1 - r2
            r0.e = r1
            goto L1b
        L16:
            io.ktor.network.sockets.o r0 = new io.ktor.network.sockets.o
            r0.<init>(r6, r9)
        L1b:
            java.lang.Object r9 = r0.f4918c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.e
            io.ktor.network.sockets.t r3 = r6.f4922b
            r4 = 1
            if (r2 == 0) goto L3b
            if (r2 != r4) goto L33
            io.ktor.network.sockets.q r7 = r0.f4917b
            java.nio.ByteBuffer r8 = r0.f4916a
            e1.AbstractC0367g.M(r9)
            r5 = r8
            r8 = r7
            r7 = r5
            goto L52
        L33:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L3b:
            e1.AbstractC0367g.M(r9)
        L3e:
            n3.p r9 = n3.p.f5928f
            r3.d(r9, r4)
            r0.f4916a = r7
            r0.f4917b = r8
            r0.e = r4
            n3.e r2 = r3.f4939p
            java.lang.Object r9 = r2.p(r3, r9, r0)
            if (r9 != r1) goto L52
            return r1
        L52:
            java.lang.String r9 = "<this>"
            J3.i.e(r8, r9)
            java.net.SocketAddress r9 = r8.c()
            java.nio.channels.DatagramChannel r2 = r6.f4921a
            int r9 = r2.send(r7, r9)
            if (r9 == 0) goto L3e
            n3.p r6 = n3.p.f5928f
            r7 = 0
            r3.d(r6, r7)
            w3.i r6 = w3.i.f6729a
            return r6
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.p.a(io.ktor.network.sockets.p, java.nio.ByteBuffer, io.ktor.network.sockets.q, A3.c):java.lang.Object");
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // S3.w
    /* JADX INFO: renamed from: b, reason: merged with bridge method [inline-methods] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object m(io.ktor.network.sockets.l r9, y3.InterfaceC0762c r10) {
        /*
            r8 = this;
            boolean r0 = r10 instanceof io.ktor.network.sockets.m
            if (r0 == 0) goto L13
            r0 = r10
            io.ktor.network.sockets.m r0 = (io.ktor.network.sockets.m) r0
            int r1 = r0.f4905f
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4905f = r1
            goto L18
        L13:
            io.ktor.network.sockets.m r0 = new io.ktor.network.sockets.m
            r0.<init>(r8, r10)
        L18:
            java.lang.Object r10 = r0.f4904d
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4905f
            r3 = 2
            r4 = 1
            r5 = 0
            if (r2 == 0) goto L44
            if (r2 == r4) goto L37
            if (r2 != r3) goto L2f
            Y3.a r9 = r0.f4902b
            e1.AbstractC0367g.M(r10)     // Catch: java.lang.Throwable -> L2d
            goto L72
        L2d:
            r10 = move-exception
            goto L7e
        L2f:
            java.lang.IllegalStateException r9 = new java.lang.IllegalStateException
            java.lang.String r10 = "call to 'resume' before 'invoke' with coroutine"
            r9.<init>(r10)
            throw r9
        L37:
            int r9 = r0.f4903c
            Y3.a r2 = r0.f4902b
            io.ktor.network.sockets.l r4 = r0.f4901a
            e1.AbstractC0367g.M(r10)
            r10 = r2
            r2 = r9
            r9 = r4
            goto L59
        L44:
            e1.AbstractC0367g.M(r10)
            r0.f4901a = r9
            Y3.d r10 = r8.f4923c
            r0.f4902b = r10
            r2 = 0
            r0.f4903c = r2
            r0.f4905f = r4
            java.lang.Object r4 = r10.c(r0)
            if (r4 != r1) goto L59
            goto L70
        L59:
            X3.e r4 = Q3.O.f1596a     // Catch: java.lang.Throwable -> L7a
            X3.d r4 = X3.d.f2437c     // Catch: java.lang.Throwable -> L7a
            io.ktor.network.sockets.n r6 = new io.ktor.network.sockets.n     // Catch: java.lang.Throwable -> L7a
            r6.<init>(r9, r8, r5)     // Catch: java.lang.Throwable -> L7a
            r0.f4901a = r5     // Catch: java.lang.Throwable -> L7a
            r0.f4902b = r10     // Catch: java.lang.Throwable -> L7a
            r0.f4903c = r2     // Catch: java.lang.Throwable -> L7a
            r0.f4905f = r3     // Catch: java.lang.Throwable -> L7a
            java.lang.Object r9 = Q3.F.B(r4, r6, r0)     // Catch: java.lang.Throwable -> L7a
            if (r9 != r1) goto L71
        L70:
            return r1
        L71:
            r9 = r10
        L72:
            Y3.d r9 = (Y3.d) r9
            r9.e(r5)
            w3.i r9 = w3.i.f6729a
            return r9
        L7a:
            r9 = move-exception
            r7 = r10
            r10 = r9
            r9 = r7
        L7e:
            Y3.d r9 = (Y3.d) r9
            r9.e(r5)
            throw r10
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.p.m(io.ktor.network.sockets.l, y3.c):java.lang.Object");
    }

    @Override // S3.w
    public final boolean j(Throwable th) {
        if (!e.compareAndSet(this, 0, 1)) {
            return false;
        }
        this.closedCause = null;
        if (!this.f4922b.f5934a.get()) {
            this.f4922b.close();
        }
        loop0: while (true) {
            I3.l lVar = (I3.l) this.onCloseHandler;
            C0152y c0152y = q.f4925b;
            if (lVar == c0152y) {
                break;
            }
            if (lVar == null) {
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f4920d;
                C0152y c0152y2 = q.f4924a;
                while (!atomicReferenceFieldUpdater.compareAndSet(this, null, c0152y2)) {
                    if (atomicReferenceFieldUpdater.get(this) != null) {
                        break;
                    }
                }
                break loop0;
            }
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = f4920d;
            while (!atomicReferenceFieldUpdater2.compareAndSet(this, lVar, c0152y)) {
                if (atomicReferenceFieldUpdater2.get(this) != lVar) {
                    throw new IllegalArgumentException("Failed requirement.");
                }
            }
            lVar.invoke(this.closedCause);
            return true;
        }
        return true;
    }
}
