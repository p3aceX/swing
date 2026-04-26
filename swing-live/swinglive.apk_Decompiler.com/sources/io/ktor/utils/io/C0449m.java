package io.ktor.utils.io;

import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: renamed from: io.ktor.utils.io.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0449m implements o, v {
    public static final /* synthetic */ AtomicReferenceFieldUpdater e = AtomicReferenceFieldUpdater.newUpdater(C0449m.class, Object.class, "suspensionSlot");

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f4991f = AtomicReferenceFieldUpdater.newUpdater(C0449m.class, Object.class, "_closedCause");
    private volatile int flushBufferSize;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Z3.a f4992a = new Z3.a();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f4993b = new Object();
    volatile /* synthetic */ Object suspensionSlot = C0439c.f4971b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Z3.a f4994c = new Z3.a();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Z3.a f4995d = new Z3.a();
    volatile /* synthetic */ Object _closedCause = null;

    /* JADX WARN: Removed duplicated region for block: B:36:0x009c  */
    /* JADX WARN: Removed duplicated region for block: B:37:0x00ad  */
    /* JADX WARN: Removed duplicated region for block: B:49:0x00d8  */
    /* JADX WARN: Removed duplicated region for block: B:51:0x00e0  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object a(int r14, y3.InterfaceC0762c r15) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 288
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.C0449m.a(int, y3.c):java.lang.Object");
    }

    public final void b() {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        d();
        D d5 = z.f5030a;
        do {
            atomicReferenceFieldUpdater = f4991f;
            if (atomicReferenceFieldUpdater.compareAndSet(this, null, d5)) {
                c(null);
                return;
            }
        } while (atomicReferenceFieldUpdater.get(this) == null);
    }

    public final void c(Throwable th) {
        C0437a c0437a;
        if (th != null) {
            c0437a = new C0437a(th);
        } else {
            InterfaceC0443g.f4976a.getClass();
            c0437a = C0438b.f4970b;
        }
        InterfaceC0443g interfaceC0443g = (InterfaceC0443g) e.getAndSet(this, c0437a);
        if (interfaceC0443g instanceof InterfaceC0441e) {
            ((InterfaceC0441e) interfaceC0443g).b(th);
        }
    }

    public final void d() {
        if (this.f4995d.w()) {
            return;
        }
        synchronized (this.f4993b) {
            Z3.a aVar = this.f4995d;
            int i4 = (int) aVar.f2603c;
            while (aVar.m(this.f4992a, 8192L) != -1) {
            }
            this.flushBufferSize += i4;
        }
        InterfaceC0443g interfaceC0443g = (InterfaceC0443g) this.suspensionSlot;
        if (interfaceC0443g instanceof C0440d) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = e;
            C0439c c0439c = C0439c.f4971b;
            while (!atomicReferenceFieldUpdater.compareAndSet(this, interfaceC0443g, c0439c)) {
                if (atomicReferenceFieldUpdater.get(this) != interfaceC0443g) {
                    return;
                }
            }
            ((InterfaceC0441e) interfaceC0443g).a();
        }
    }

    public final Z3.h e() throws Throwable {
        Throwable thA;
        D d5 = (D) this._closedCause;
        if (d5 != null && (thA = d5.a(C0447k.f4989o)) != null) {
            throw thA;
        }
        if (this.f4994c.w()) {
            j();
        }
        return this.f4994c;
    }

    public final boolean f() {
        if (o() == null) {
            return g() && this.flushBufferSize == 0 && this.f4994c.w();
        }
        return true;
    }

    public final boolean g() {
        return this._closedCause != null;
    }

    @Override // io.ktor.utils.io.v
    public final Z3.a h() throws Throwable {
        Throwable thA;
        if (!g()) {
            return this.f4995d;
        }
        D d5 = (D) this._closedCause;
        if (d5 == null || (thA = d5.a(C0448l.f4990o)) == null) {
            throw new G(null, null);
        }
        throw thA;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // io.ktor.utils.io.v
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object i(y3.InterfaceC0762c r5) {
        /*
            r4 = this;
            boolean r0 = r5 instanceof io.ktor.utils.io.C0446j
            if (r0 == 0) goto L13
            r0 = r5
            io.ktor.utils.io.j r0 = (io.ktor.utils.io.C0446j) r0
            int r1 = r0.f4988c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f4988c = r1
            goto L18
        L13:
            io.ktor.utils.io.j r0 = new io.ktor.utils.io.j
            r0.<init>(r4, r5)
        L18:
            java.lang.Object r5 = r0.f4986a
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f4988c
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            e1.AbstractC0367g.M(r5)     // Catch: java.lang.Throwable -> L27
            goto L40
        L27:
            r5 = move-exception
            goto L3d
        L29:
            java.lang.IllegalStateException r5 = new java.lang.IllegalStateException
            java.lang.String r0 = "call to 'resume' before 'invoke' with coroutine"
            r5.<init>(r0)
            throw r5
        L31:
            e1.AbstractC0367g.M(r5)
            r0.f4988c = r3     // Catch: java.lang.Throwable -> L27
            java.lang.Object r5 = r4.n(r0)     // Catch: java.lang.Throwable -> L27
            if (r5 != r1) goto L40
            return r1
        L3d:
            e1.AbstractC0367g.h(r5)
        L40:
            io.ktor.utils.io.D r5 = io.ktor.utils.io.z.f5030a
        L42:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r0 = io.ktor.utils.io.C0449m.f4991f
            r1 = 0
            boolean r2 = r0.compareAndSet(r4, r1, r5)
            w3.i r3 = w3.i.f6729a
            if (r2 == 0) goto L51
            r4.c(r1)
            return r3
        L51:
            java.lang.Object r0 = r0.get(r4)
            if (r0 == 0) goto L42
            return r3
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.C0449m.i(y3.c):java.lang.Object");
    }

    public final void j() {
        synchronized (this.f4993b) {
            Z3.a aVar = this.f4992a;
            Z3.a aVar2 = this.f4994c;
            long j4 = aVar.f2603c;
            if (j4 > 0) {
                aVar2.i(aVar, j4);
            }
            this.flushBufferSize = 0;
        }
        InterfaceC0443g interfaceC0443g = (InterfaceC0443g) this.suspensionSlot;
        if (interfaceC0443g instanceof C0442f) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = e;
            C0439c c0439c = C0439c.f4971b;
            while (!atomicReferenceFieldUpdater.compareAndSet(this, interfaceC0443g, c0439c)) {
                if (atomicReferenceFieldUpdater.get(this) != interfaceC0443g) {
                    return;
                }
            }
            ((InterfaceC0441e) interfaceC0443g).a();
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:35:0x008c  */
    /* JADX WARN: Removed duplicated region for block: B:36:0x009d  */
    /* JADX WARN: Removed duplicated region for block: B:48:0x00c0  */
    /* JADX WARN: Removed duplicated region for block: B:50:0x00c8  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    @Override // io.ktor.utils.io.v
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object n(A3.c r13) throws java.lang.Throwable {
        /*
            Method dump skipped, instruction units count: 237
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.ktor.utils.io.C0449m.n(A3.c):java.lang.Object");
    }

    @Override // io.ktor.utils.io.v
    public final Throwable o() {
        D d5 = (D) this._closedCause;
        if (d5 != null) {
            return d5.a(C.f4955o);
        }
        return null;
    }

    @Override // io.ktor.utils.io.v
    public final void t(Throwable th) {
        if (this._closedCause != null) {
            return;
        }
        D d5 = new D(th);
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f4991f;
        while (!atomicReferenceFieldUpdater.compareAndSet(this, null, d5) && atomicReferenceFieldUpdater.get(this) == null) {
        }
        c(d5.a(C.f4955o));
    }

    public final String toString() {
        return "ByteChannel[" + hashCode() + ']';
    }

    @Override // io.ktor.utils.io.v
    public final boolean u() {
        return false;
    }
}
