package io.ktor.network.sockets;

import Q3.C0136j0;
import Q3.InterfaceC0132h0;
import Q3.q0;
import io.ktor.utils.io.C0449m;
import io.ktor.utils.io.J;
import io.ktor.utils.io.L;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public abstract class A extends n3.r implements x, Q3.D {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f4830f = AtomicIntegerFieldUpdater.newUpdater(A.class, "closeFlag");

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f4831m = AtomicIntegerFieldUpdater.newUpdater(A.class, "actualCloseFlag");

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f4832n = AtomicReferenceFieldUpdater.newUpdater(A.class, Object.class, "readerJob");

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f4833o = AtomicReferenceFieldUpdater.newUpdater(A.class, Object.class, "writerJob");
    private volatile /* synthetic */ int closeFlag = 0;
    private volatile /* synthetic */ int actualCloseFlag = 0;
    volatile /* synthetic */ Object readerJob = null;
    volatile /* synthetic */ Object writerJob = null;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final M1.b f4834d = new M1.b(this, 1);
    public final C0136j0 e = new C0136j0(null);

    @Override // n3.r, java.io.Closeable, java.lang.AutoCloseable
    public void close() {
        if (f4830f.compareAndSet(this, 0, 1)) {
            Q3.F.s(this, new Q3.C("socket-close"), new z(this, null), 2);
        }
    }

    @Override // io.ktor.network.sockets.InterfaceC0429a
    public final InterfaceC0132h0 e() {
        return this.e;
    }

    public abstract Throwable f();

    public abstract L g(C0449m c0449m);

    public abstract J h(C0449m c0449m);

    /* JADX WARN: Removed duplicated region for block: B:25:0x0054  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void i() throws java.lang.IllegalAccessException, java.lang.reflect.InvocationTargetException {
        /*
            r5 = this;
            int r0 = r5.closeFlag
            if (r0 == 0) goto Lad
            java.lang.Object r0 = r5.readerJob
            io.ktor.utils.io.A r0 = (io.ktor.utils.io.A) r0
            if (r0 == 0) goto L14
            Q3.h0 r0 = r0.a()
            boolean r0 = r0.l()
            if (r0 == 0) goto Lad
        L14:
            java.lang.Object r0 = r5.writerJob
            io.ktor.utils.io.A r0 = (io.ktor.utils.io.A) r0
            if (r0 == 0) goto L24
            Q3.h0 r0 = r0.a()
            boolean r0 = r0.l()
            if (r0 == 0) goto Lad
        L24:
            java.util.concurrent.atomic.AtomicIntegerFieldUpdater r0 = io.ktor.network.sockets.A.f4831m
            r1 = 1
            r2 = 0
            boolean r0 = r0.compareAndSet(r5, r2, r1)
            if (r0 != 0) goto L30
            goto Lad
        L30:
            java.lang.Object r0 = r5.readerJob
            io.ktor.utils.io.A r0 = (io.ktor.utils.io.A) r0
            r1 = 0
            if (r0 == 0) goto L54
            Q3.h0 r3 = r0.a()
            boolean r3 = r3.isCancelled()
            if (r3 == 0) goto L42
            goto L43
        L42:
            r0 = r1
        L43:
            if (r0 == 0) goto L54
            Q3.h0 r0 = r0.a()
            java.util.concurrent.CancellationException r0 = r0.f()
            if (r0 == 0) goto L54
            java.lang.Throwable r0 = r0.getCause()
            goto L55
        L54:
            r0 = r1
        L55:
            java.lang.Object r3 = r5.writerJob
            io.ktor.utils.io.A r3 = (io.ktor.utils.io.A) r3
            if (r3 == 0) goto L77
            Q3.h0 r4 = r3.a()
            boolean r4 = r4.isCancelled()
            if (r4 == 0) goto L66
            goto L67
        L66:
            r3 = r1
        L67:
            if (r3 == 0) goto L77
            Q3.h0 r3 = r3.a()
            java.util.concurrent.CancellationException r3 = r3.f()
            if (r3 == 0) goto L77
            java.lang.Throwable r1 = r3.getCause()
        L77:
            java.lang.Throwable r3 = r5.f()
            if (r0 != 0) goto L7f
            r0 = r1
            goto L88
        L7f:
            if (r1 != 0) goto L82
            goto L88
        L82:
            if (r0 != r1) goto L85
            goto L88
        L85:
            e1.k.b(r0, r1)
        L88:
            if (r0 != 0) goto L8b
            goto L96
        L8b:
            if (r3 != 0) goto L8e
            goto L90
        L8e:
            if (r0 != r3) goto L92
        L90:
            r3 = r0
            goto L96
        L92:
            e1.k.b(r0, r3)
            goto L90
        L96:
            if (r3 != 0) goto La0
            Q3.j0 r0 = r5.e
            w3.i r1 = w3.i.f6729a
            r0.O(r1)
            return
        La0:
            Q3.j0 r0 = r5.e
            r0.getClass()
            Q3.v r1 = new Q3.v
            r1.<init>(r3, r2)
            r0.O(r1)
        Lad:
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.network.sockets.A.i():void");
    }

    @Override // io.ktor.network.sockets.x
    public final L j(C0449m c0449m) throws IOException {
        if (this.closeFlag != 0) {
            IOException iOException = new IOException("Socket closed");
            c0449m.t(iOException);
            throw iOException;
        }
        L lG = g(c0449m);
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f4833o;
        while (!atomicReferenceFieldUpdater.compareAndSet(this, null, lG)) {
            if (atomicReferenceFieldUpdater.get(this) != null) {
                IllegalStateException illegalStateException = new IllegalStateException("reading channel has already been set");
                io.ktor.utils.io.z.a(lG);
                throw illegalStateException;
            }
        }
        if (this.closeFlag != 0) {
            IOException iOException2 = new IOException("Socket closed");
            io.ktor.utils.io.z.a(lG);
            c0449m.t(iOException2);
            throw iOException2;
        }
        ((q0) lG.a()).q(new io.ktor.utils.io.n(c0449m, 0));
        M1.b bVar = this.f4834d;
        J3.i.e(bVar, "block");
        ((q0) lG.a()).q(bVar);
        return lG;
    }

    @Override // Q3.D
    public final InterfaceC0767h n() {
        return this.e;
    }

    @Override // io.ktor.network.sockets.x
    public final J u(C0449m c0449m) throws IOException {
        if (this.closeFlag != 0) {
            IOException iOException = new IOException("Socket closed");
            c0449m.t(iOException);
            throw iOException;
        }
        J jH = h(c0449m);
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f4832n;
        while (!atomicReferenceFieldUpdater.compareAndSet(this, null, jH)) {
            if (atomicReferenceFieldUpdater.get(this) != null) {
                IllegalStateException illegalStateException = new IllegalStateException("writing channel has already been set");
                io.ktor.utils.io.z.a(jH);
                throw illegalStateException;
            }
        }
        if (this.closeFlag != 0) {
            IOException iOException2 = new IOException("Socket closed");
            io.ktor.utils.io.z.a(jH);
            c0449m.t(iOException2);
            throw iOException2;
        }
        ((q0) jH.a()).q(new io.ktor.utils.io.n(c0449m, 0));
        M1.b bVar = this.f4834d;
        J3.i.e(bVar, "block");
        ((q0) jH.a()).q(bVar);
        return jH;
    }
}
