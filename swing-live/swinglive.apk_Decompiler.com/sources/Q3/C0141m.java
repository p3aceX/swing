package Q3;

import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.CancellationException;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: renamed from: Q3.m, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0141m extends N implements InterfaceC0137k, A3.d, K0 {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f1638f = AtomicIntegerFieldUpdater.newUpdater(C0141m.class, "_decisionAndIndex$volatile");

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1639m = AtomicReferenceFieldUpdater.newUpdater(C0141m.class, Object.class, "_state$volatile");

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1640n = AtomicReferenceFieldUpdater.newUpdater(C0141m.class, Object.class, "_parentHandle$volatile");
    private volatile /* synthetic */ int _decisionAndIndex$volatile;
    private volatile /* synthetic */ Object _parentHandle$volatile;
    private volatile /* synthetic */ Object _state$volatile;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final InterfaceC0762c f1641d;
    public final InterfaceC0767h e;

    public C0141m(int i4, InterfaceC0762c interfaceC0762c) {
        super(i4);
        this.f1641d = interfaceC0762c;
        this.e = interfaceC0762c.getContext();
        this._decisionAndIndex$volatile = 536870911;
        this._state$volatile = C0119b.f1613a;
    }

    public static Object C(v0 v0Var, Object obj, int i4, I3.q qVar) {
        if (obj instanceof C0149v) {
            return obj;
        }
        if (i4 != 1 && i4 != 2) {
            return obj;
        }
        if (qVar != null || (v0Var instanceof InterfaceC0135j)) {
            return new C0148u(obj, v0Var instanceof InterfaceC0135j ? (InterfaceC0135j) v0Var : null, qVar, (CancellationException) null, 16);
        }
        return obj;
    }

    public static void w(v0 v0Var, Object obj) {
        throw new IllegalStateException(("It's prohibited to register multiple handlers, tried to register " + v0Var + ", already has " + obj).toString());
    }

    public final void A(Object obj, int i4, I3.q qVar) throws IllegalAccessException, L, InvocationTargetException {
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1639m;
            Object obj2 = atomicReferenceFieldUpdater.get(this);
            if (obj2 instanceof v0) {
                Object objC = C((v0) obj2, obj, i4, qVar);
                while (!atomicReferenceFieldUpdater.compareAndSet(this, obj2, objC)) {
                    if (atomicReferenceFieldUpdater.get(this) != obj2) {
                        break;
                    }
                }
                if (!v()) {
                    m();
                }
                n(i4);
                return;
            }
            if (obj2 instanceof C0142n) {
                C0142n c0142n = (C0142n) obj2;
                c0142n.getClass();
                if (C0142n.f1643c.compareAndSet(c0142n, 0, 1)) {
                    if (qVar != null) {
                        j(qVar, c0142n.f1666a, obj);
                        return;
                    }
                    return;
                }
            }
            throw new IllegalStateException(("Already resumed, but proposed with update " + obj).toString());
        }
    }

    public final void B(A a5) {
        w3.i iVar = w3.i.f6729a;
        InterfaceC0762c interfaceC0762c = this.f1641d;
        V3.g gVar = interfaceC0762c instanceof V3.g ? (V3.g) interfaceC0762c : null;
        A(iVar, (gVar != null ? gVar.f2224d : null) == a5 ? 4 : this.f1595c, null);
    }

    public final C0779j D(Object obj, I3.q qVar) {
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1639m;
            Object obj2 = atomicReferenceFieldUpdater.get(this);
            boolean z4 = obj2 instanceof v0;
            C0779j c0779j = F.f1576a;
            if (!z4) {
                boolean z5 = obj2 instanceof C0148u;
                return null;
            }
            Object objC = C((v0) obj2, obj, this.f1595c, qVar);
            while (!atomicReferenceFieldUpdater.compareAndSet(this, obj2, objC)) {
                if (atomicReferenceFieldUpdater.get(this) != obj2) {
                    break;
                }
            }
            if (!v()) {
                m();
            }
            return c0779j;
        }
    }

    @Override // Q3.K0
    public final void a(V3.s sVar, int i4) {
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater;
        int i5;
        do {
            atomicIntegerFieldUpdater = f1638f;
            i5 = atomicIntegerFieldUpdater.get(this);
            if ((i5 & 536870911) != 536870911) {
                throw new IllegalStateException("invokeOnCancellation should be called at most once");
            }
        } while (!atomicIntegerFieldUpdater.compareAndSet(this, i5, ((i5 >> 29) << 29) + i4));
        u(sVar);
    }

    @Override // Q3.N
    public final void b(CancellationException cancellationException) throws IllegalAccessException, InvocationTargetException {
        CancellationException cancellationException2;
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1639m;
            Object obj = atomicReferenceFieldUpdater.get(this);
            if (obj instanceof v0) {
                throw new IllegalStateException("Not completed");
            }
            if (obj instanceof C0149v) {
                return;
            }
            if (!(obj instanceof C0148u)) {
                cancellationException2 = cancellationException;
                C0148u c0148u = new C0148u(obj, (InterfaceC0135j) null, (I3.q) null, cancellationException2, 14);
                while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, c0148u)) {
                    if (atomicReferenceFieldUpdater.get(this) != obj) {
                        break;
                    }
                }
                return;
            }
            C0148u c0148u2 = (C0148u) obj;
            if (c0148u2.e != null) {
                throw new IllegalStateException("Must be called at most once");
            }
            C0148u c0148uA = C0148u.a(c0148u2, null, cancellationException, 15);
            while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, c0148uA)) {
                if (atomicReferenceFieldUpdater.get(this) != obj) {
                    cancellationException2 = cancellationException;
                }
            }
            InterfaceC0135j interfaceC0135j = c0148u2.f1661b;
            if (interfaceC0135j != null) {
                i(interfaceC0135j, cancellationException);
            }
            I3.q qVar = c0148u2.f1662c;
            if (qVar != null) {
                j(qVar, cancellationException, c0148u2.f1660a);
                return;
            }
            return;
            cancellationException = cancellationException2;
        }
    }

    @Override // Q3.N
    public final InterfaceC0762c c() {
        return this.f1641d;
    }

    @Override // Q3.N
    public final Throwable d(Object obj) {
        Throwable thD = super.d(obj);
        if (thD != null) {
            return thD;
        }
        return null;
    }

    @Override // Q3.InterfaceC0137k
    public final C0779j e(Object obj, I3.q qVar) {
        return D(obj, qVar);
    }

    @Override // Q3.N
    public final Object f(Object obj) {
        return obj instanceof C0148u ? ((C0148u) obj).f1660a : obj;
    }

    @Override // A3.d
    public final A3.d getCallerFrame() {
        InterfaceC0762c interfaceC0762c = this.f1641d;
        if (interfaceC0762c instanceof A3.d) {
            return (A3.d) interfaceC0762c;
        }
        return null;
    }

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        return this.e;
    }

    @Override // Q3.N
    public final Object h() {
        return f1639m.get(this);
    }

    public final void i(InterfaceC0135j interfaceC0135j, Throwable th) throws IllegalAccessException, InvocationTargetException {
        try {
            interfaceC0135j.a(th);
        } catch (Throwable th2) {
            F.o(new A0.b("Exception in invokeOnCancellation handler for " + this, th2), this.e);
        }
    }

    public final void j(I3.q qVar, Throwable th, Object obj) throws IllegalAccessException, InvocationTargetException {
        InterfaceC0767h interfaceC0767h = this.e;
        try {
            qVar.b(th, obj, interfaceC0767h);
        } catch (Throwable th2) {
            F.o(new A0.b("Exception in resume onCancellation handler for " + this, th2), interfaceC0767h);
        }
    }

    public final void k(V3.s sVar, Throwable th) throws IllegalAccessException, InvocationTargetException {
        InterfaceC0767h interfaceC0767h = this.e;
        int i4 = f1638f.get(this) & 536870911;
        if (i4 == 536870911) {
            throw new IllegalStateException("The index for Segment.onCancellation(..) is broken");
        }
        try {
            sVar.h(i4, interfaceC0767h);
        } catch (Throwable th2) {
            F.o(new A0.b("Exception in invokeOnCancellation handler for " + this, th2), interfaceC0767h);
        }
    }

    public final void l(Throwable th) throws IllegalAccessException, L, InvocationTargetException {
        Throwable cancellationException;
        while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1639m;
            Object obj = atomicReferenceFieldUpdater.get(this);
            if (obj instanceof v0) {
                boolean z4 = (obj instanceof InterfaceC0135j) || (obj instanceof V3.s);
                if (th == null) {
                    cancellationException = new CancellationException("Continuation " + this + " was cancelled normally");
                } else {
                    cancellationException = th;
                }
                C0142n c0142n = new C0142n(cancellationException, z4);
                while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, c0142n)) {
                    if (atomicReferenceFieldUpdater.get(this) != obj) {
                        break;
                    }
                }
                v0 v0Var = (v0) obj;
                if (v0Var instanceof InterfaceC0135j) {
                    i((InterfaceC0135j) obj, th);
                } else if (v0Var instanceof V3.s) {
                    k((V3.s) obj, th);
                }
                if (!v()) {
                    m();
                }
                n(this.f1595c);
                return;
            }
            return;
        }
    }

    public final void m() {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1640n;
        Q q4 = (Q) atomicReferenceFieldUpdater.get(this);
        if (q4 == null) {
            return;
        }
        q4.a();
        atomicReferenceFieldUpdater.set(this, u0.f1664a);
    }

    public final void n(int i4) throws L {
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater;
        int i5;
        do {
            atomicIntegerFieldUpdater = f1638f;
            i5 = atomicIntegerFieldUpdater.get(this);
            int i6 = i5 >> 29;
            if (i6 != 0) {
                if (i6 != 1) {
                    throw new IllegalStateException("Already resumed");
                }
                InterfaceC0762c interfaceC0762c = this.f1641d;
                boolean z4 = i4 == 4;
                if (!z4 && (interfaceC0762c instanceof V3.g)) {
                    boolean z5 = i4 == 1 || i4 == 2;
                    int i7 = this.f1595c;
                    if (z5 == (i7 == 1 || i7 == 2)) {
                        V3.g gVar = (V3.g) interfaceC0762c;
                        A a5 = gVar.f2224d;
                        InterfaceC0767h context = gVar.e.getContext();
                        if (V3.b.j(a5, context)) {
                            V3.b.i(a5, context, this);
                            return;
                        }
                        Z zA = B0.a();
                        if (zA.f1610c >= 4294967296L) {
                            zA.F(this);
                            return;
                        }
                        zA.H(true);
                        try {
                            F.v(this, interfaceC0762c, true);
                            do {
                            } while (zA.J());
                        } finally {
                            try {
                            } finally {
                            }
                        }
                        return;
                    }
                }
                F.v(this, interfaceC0762c, z4);
                return;
            }
        } while (!atomicIntegerFieldUpdater.compareAndSet(this, i5, 1073741824 + (536870911 & i5)));
    }

    @Override // Q3.InterfaceC0137k
    public final void o(Object obj) throws L {
        n(this.f1595c);
    }

    public Throwable p(q0 q0Var) {
        return q0Var.f();
    }

    public final Object q() {
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater;
        int i4;
        boolean zV = v();
        do {
            atomicIntegerFieldUpdater = f1638f;
            i4 = atomicIntegerFieldUpdater.get(this);
            int i5 = i4 >> 29;
            if (i5 != 0) {
                if (i5 != 2) {
                    throw new IllegalStateException("Already suspended");
                }
                if (zV) {
                    y();
                }
                Object obj = f1639m.get(this);
                if (obj instanceof C0149v) {
                    throw ((C0149v) obj).f1666a;
                }
                int i6 = this.f1595c;
                if (i6 == 1 || i6 == 2) {
                    InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) this.e.i(B.f1565b);
                    if (interfaceC0132h0 != null && !interfaceC0132h0.b()) {
                        CancellationException cancellationExceptionF = interfaceC0132h0.f();
                        b(cancellationExceptionF);
                        throw cancellationExceptionF;
                    }
                }
                return f(obj);
            }
        } while (!atomicIntegerFieldUpdater.compareAndSet(this, i4, 536870912 + (536870911 & i4)));
        if (((Q) f1640n.get(this)) == null) {
            s();
        }
        if (zV) {
            y();
        }
        return EnumC0789a.f6999a;
    }

    public final void r() {
        Q qS = s();
        if (qS == null || (f1639m.get(this) instanceof v0)) {
            return;
        }
        qS.a();
        f1640n.set(this, u0.f1664a);
    }

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) throws IllegalAccessException, L, InvocationTargetException {
        Throwable thA = w3.e.a(obj);
        if (thA != null) {
            obj = new C0149v(thA, false);
        }
        A(obj, this.f1595c, null);
    }

    public final Q s() {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) this.e.i(B.f1565b);
        if (interfaceC0132h0 == null) {
            return null;
        }
        Q qP = F.p(interfaceC0132h0, true, new C0143o(this, 0));
        do {
            atomicReferenceFieldUpdater = f1640n;
            if (atomicReferenceFieldUpdater.compareAndSet(this, null, qP)) {
                break;
            }
        } while (atomicReferenceFieldUpdater.get(this) == null);
        return qP;
    }

    public final void t(I3.l lVar) {
        u(new C0133i(lVar, 1));
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(x());
        sb.append('(');
        sb.append(F.y(this.f1641d));
        sb.append("){");
        Object obj = f1639m.get(this);
        sb.append(obj instanceof v0 ? "Active" : obj instanceof C0142n ? "Cancelled" : "Completed");
        sb.append("}@");
        sb.append(F.l(this));
        return sb.toString();
    }

    /* JADX WARN: Code restructure failed: missing block: B:63:0x00aa, code lost:
    
        w(r8, r2);
     */
    /* JADX WARN: Code restructure failed: missing block: B:64:0x00ad, code lost:
    
        throw null;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void u(Q3.v0 r8) {
        /*
            r7 = this;
        L0:
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r0 = Q3.C0141m.f1639m
            java.lang.Object r2 = r0.get(r7)
            boolean r1 = r2 instanceof Q3.C0119b
            if (r1 == 0) goto L19
        La:
            boolean r1 = r0.compareAndSet(r7, r2, r8)
            if (r1 == 0) goto L12
            goto La1
        L12:
            java.lang.Object r1 = r0.get(r7)
            if (r1 == r2) goto La
            goto L0
        L19:
            boolean r1 = r2 instanceof Q3.InterfaceC0135j
            r3 = 0
            if (r1 != 0) goto Laa
            boolean r1 = r2 instanceof V3.s
            if (r1 != 0) goto Laa
            boolean r1 = r2 instanceof Q3.C0149v
            if (r1 == 0) goto L56
            r0 = r2
            Q3.v r0 = (Q3.C0149v) r0
            r0.getClass()
            r1 = 1
            java.util.concurrent.atomic.AtomicIntegerFieldUpdater r4 = Q3.C0149v.f1665b
            r5 = 0
            boolean r1 = r4.compareAndSet(r0, r5, r1)
            if (r1 == 0) goto L52
            boolean r1 = r2 instanceof Q3.C0142n
            if (r1 == 0) goto La1
            if (r2 == 0) goto L3d
            goto L3e
        L3d:
            r0 = r3
        L3e:
            if (r0 == 0) goto L42
            java.lang.Throwable r3 = r0.f1666a
        L42:
            boolean r0 = r8 instanceof Q3.InterfaceC0135j
            if (r0 == 0) goto L4c
            Q3.j r8 = (Q3.InterfaceC0135j) r8
            r7.i(r8, r3)
            return
        L4c:
            V3.s r8 = (V3.s) r8
            r7.k(r8, r3)
            return
        L52:
            w(r8, r2)
            throw r3
        L56:
            boolean r1 = r2 instanceof Q3.C0148u
            if (r1 == 0) goto L8a
            r1 = r2
            Q3.u r1 = (Q3.C0148u) r1
            Q3.j r4 = r1.f1661b
            if (r4 != 0) goto L86
            boolean r4 = r8 instanceof V3.s
            if (r4 == 0) goto L66
            goto La1
        L66:
            r4 = r8
            Q3.j r4 = (Q3.InterfaceC0135j) r4
            java.lang.Throwable r5 = r1.e
            if (r5 == 0) goto L71
            r7.i(r4, r5)
            return
        L71:
            r5 = 29
            Q3.u r1 = Q3.C0148u.a(r1, r4, r3, r5)
        L77:
            boolean r3 = r0.compareAndSet(r7, r2, r1)
            if (r3 == 0) goto L7e
            goto La1
        L7e:
            java.lang.Object r3 = r0.get(r7)
            if (r3 == r2) goto L77
            goto L0
        L86:
            w(r8, r2)
            throw r3
        L8a:
            boolean r1 = r8 instanceof V3.s
            if (r1 == 0) goto L8f
            goto La1
        L8f:
            r3 = r8
            Q3.j r3 = (Q3.InterfaceC0135j) r3
            Q3.u r1 = new Q3.u
            r4 = 0
            r5 = 0
            r6 = 28
            r1.<init>(r2, r3, r4, r5, r6)
        L9b:
            boolean r3 = r0.compareAndSet(r7, r2, r1)
            if (r3 == 0) goto La2
        La1:
            return
        La2:
            java.lang.Object r3 = r0.get(r7)
            if (r3 == r2) goto L9b
            goto L0
        Laa:
            w(r8, r2)
            throw r3
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.C0141m.u(Q3.v0):void");
    }

    public final boolean v() {
        if (this.f1595c != 2) {
            return false;
        }
        InterfaceC0762c interfaceC0762c = this.f1641d;
        J3.i.c(interfaceC0762c, "null cannot be cast to non-null type kotlinx.coroutines.internal.DispatchedContinuation<*>");
        return V3.g.f2223n.get((V3.g) interfaceC0762c) != null;
    }

    public String x() {
        return "CancellableContinuation";
    }

    public final void y() throws IllegalAccessException, L, InvocationTargetException {
        InterfaceC0762c interfaceC0762c = this.f1641d;
        Throwable th = null;
        V3.g gVar = interfaceC0762c instanceof V3.g ? (V3.g) interfaceC0762c : null;
        if (gVar != null) {
            loop0: while (true) {
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = V3.g.f2223n;
                Object obj = atomicReferenceFieldUpdater.get(gVar);
                C0779j c0779j = V3.b.f2214c;
                if (obj == c0779j) {
                    while (!atomicReferenceFieldUpdater.compareAndSet(gVar, c0779j, this)) {
                        if (atomicReferenceFieldUpdater.get(gVar) != c0779j) {
                            break;
                        }
                    }
                    break loop0;
                } else {
                    if (!(obj instanceof Throwable)) {
                        throw new IllegalStateException(("Inconsistent state " + obj).toString());
                    }
                    while (!atomicReferenceFieldUpdater.compareAndSet(gVar, obj, null)) {
                        if (atomicReferenceFieldUpdater.get(gVar) != obj) {
                            throw new IllegalArgumentException("Failed requirement.");
                        }
                    }
                    th = (Throwable) obj;
                }
            }
            if (th == null) {
                return;
            }
            m();
            l(th);
        }
    }

    public final void z(Object obj, I3.q qVar) throws IllegalAccessException, L, InvocationTargetException {
        A(obj, this.f1595c, qVar);
    }
}
