package Q3;

import a.AbstractC0184a;
import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import java.util.concurrent.locks.LockSupport;
import y3.C0763d;
import y3.C0768i;
import y3.InterfaceC0762c;
import y3.InterfaceC0765f;
import y3.InterfaceC0767h;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public abstract class F {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0779j f1577b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0779j f1578c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0779j f1579d;
    public static final C0779j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final C0779j f1580f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final C0779j f1581g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public static final C0779j f1582h;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0779j f1576a = new C0779j("RESUME_TOKEN", 20);

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public static final T f1583i = new T(false);

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public static final T f1584j = new T(true);

    static {
        int i4 = 20;
        f1577b = new C0779j("REMOVED_TASK", i4);
        f1578c = new C0779j("CLOSED_EMPTY", i4);
        int i5 = 20;
        f1579d = new C0779j("COMPLETING_ALREADY", i5);
        e = new C0779j("COMPLETING_WAITING_CHILDREN", i5);
        f1580f = new C0779j("COMPLETING_RETRY", i5);
        f1581g = new C0779j("TOO_LATE_TO_CANCEL", i5);
        f1582h = new C0779j("SEALED", i5);
    }

    public static final I0 A(InterfaceC0762c interfaceC0762c, InterfaceC0767h interfaceC0767h, Object obj) {
        I0 i02 = null;
        if ((interfaceC0762c instanceof A3.d) && interfaceC0767h.i(J0.f1592a) != null) {
            A3.d callerFrame = (A3.d) interfaceC0762c;
            while (true) {
                if ((callerFrame instanceof M) || (callerFrame = callerFrame.getCallerFrame()) == null) {
                    break;
                }
                if (callerFrame instanceof I0) {
                    i02 = (I0) callerFrame;
                    break;
                }
            }
            if (i02 != null) {
                i02.i0(interfaceC0767h, obj);
            }
        }
        return i02;
    }

    public static final Object B(InterfaceC0767h interfaceC0767h, I3.p pVar, InterfaceC0762c interfaceC0762c) throws Throwable {
        Object objZ;
        InterfaceC0767h context = interfaceC0762c.getContext();
        InterfaceC0767h interfaceC0767hS = !((Boolean) interfaceC0767h.h(Boolean.FALSE, new C0151x(0))).booleanValue() ? context.s(interfaceC0767h) : j(context, interfaceC0767h, false);
        i(interfaceC0767hS);
        if (interfaceC0767hS == context) {
            V3.r rVar = new V3.r(interfaceC0762c, interfaceC0767hS);
            objZ = H0.a.f0(rVar, true, rVar, pVar);
        } else {
            C0763d c0763d = C0763d.f6944a;
            if (J3.i.a(interfaceC0767hS.i(c0763d), context.i(c0763d))) {
                I0 i02 = new I0(interfaceC0762c, interfaceC0767hS);
                InterfaceC0767h interfaceC0767h2 = i02.f1612c;
                Object objN = V3.b.n(interfaceC0767h2, null);
                try {
                    Object objF0 = H0.a.f0(i02, true, i02, pVar);
                    V3.b.g(interfaceC0767h2, objN);
                    objZ = objF0;
                } catch (Throwable th) {
                    V3.b.g(interfaceC0767h2, objN);
                    throw th;
                }
            } else {
                M m4 = new M(interfaceC0762c, interfaceC0767hS);
                try {
                    V3.b.h(w3.i.f6729a, e1.k.w(e1.k.l(pVar, m4, m4)));
                    while (true) {
                        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = M.e;
                        int i4 = atomicIntegerFieldUpdater.get(m4);
                        if (i4 != 0) {
                            if (i4 != 2) {
                                throw new IllegalStateException("Already suspended");
                            }
                            objZ = z(q0.f1656a.get(m4));
                            if (objZ instanceof C0149v) {
                                throw ((C0149v) objZ).f1666a;
                            }
                        } else if (atomicIntegerFieldUpdater.compareAndSet(m4, 0, 1)) {
                            objZ = EnumC0789a.f6999a;
                            break;
                        }
                    }
                } catch (Throwable th2) {
                    AbstractC0184a.B(m4, th2);
                    throw null;
                }
            }
        }
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        return objZ;
    }

    public static final Object C(long j4, I3.p pVar, A3.c cVar) {
        if (j4 <= 0) {
            throw new E0("Timed out immediately", null);
        }
        Object objX = x(new F0(j4, cVar), pVar);
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        return objX;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object D(long r6, I3.p r8, A3.c r9) {
        /*
            boolean r0 = r9 instanceof Q3.G0
            if (r0 == 0) goto L13
            r0 = r9
            Q3.G0 r0 = (Q3.G0) r0
            int r1 = r0.f1589c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f1589c = r1
            goto L18
        L13:
            Q3.G0 r0 = new Q3.G0
            r0.<init>(r9)
        L18:
            java.lang.Object r9 = r0.f1588b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f1589c
            r3 = 1
            if (r2 == 0) goto L33
            if (r2 != r3) goto L2b
            J3.r r6 = r0.f1587a
            e1.AbstractC0367g.M(r9)     // Catch: Q3.E0 -> L29
            return r9
        L29:
            r7 = move-exception
            goto L57
        L2b:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L33:
            e1.AbstractC0367g.M(r9)
            r4 = 0
            int r9 = (r6 > r4 ? 1 : (r6 == r4 ? 0 : -1))
            if (r9 > 0) goto L3d
            goto L5d
        L3d:
            J3.r r9 = new J3.r
            r9.<init>()
            r0.f1587a = r9     // Catch: Q3.E0 -> L55
            r0.f1589c = r3     // Catch: Q3.E0 -> L55
            Q3.F0 r2 = new Q3.F0     // Catch: Q3.E0 -> L55
            r2.<init>(r6, r0)     // Catch: Q3.E0 -> L55
            r9.f832a = r2     // Catch: Q3.E0 -> L55
            java.lang.Object r6 = x(r2, r8)     // Catch: Q3.E0 -> L55
            if (r6 != r1) goto L54
            return r1
        L54:
            return r6
        L55:
            r7 = move-exception
            r6 = r9
        L57:
            Q3.F0 r8 = r7.f1575a
            java.lang.Object r6 = r6.f832a
            if (r8 != r6) goto L5f
        L5d:
            r6 = 0
            return r6
        L5f:
            throw r7
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.F.D(long, I3.p, A3.c):java.lang.Object");
    }

    public static final Object E(A3.c cVar) {
        Object obj;
        InterfaceC0767h context = cVar.getContext();
        i(context);
        InterfaceC0762c interfaceC0762cW = e1.k.w(cVar);
        V3.g gVar = interfaceC0762cW instanceof V3.g ? (V3.g) interfaceC0762cW : null;
        w3.i iVar = w3.i.f6729a;
        if (gVar == null) {
            obj = iVar;
        } else {
            A a5 = gVar.f2224d;
            if (V3.b.j(a5, context)) {
                gVar.f2225f = iVar;
                gVar.f1595c = 1;
                a5.B(context, gVar);
            } else {
                InterfaceC0767h interfaceC0767hS = context.s(new L0(L0.f1594b));
                gVar.f2225f = iVar;
                gVar.f1595c = 1;
                a5.B(interfaceC0767hS, gVar);
            }
            obj = EnumC0789a.f6999a;
        }
        return obj == EnumC0789a.f6999a ? obj : iVar;
    }

    public static C0146s a() {
        C0146s c0146s = new C0146s(true);
        c0146s.L(null);
        return c0146s;
    }

    public static final V3.d b(InterfaceC0767h interfaceC0767h) {
        if (interfaceC0767h.i(B.f1565b) == null) {
            interfaceC0767h = interfaceC0767h.s(new C0136j0(null));
        }
        return new V3.d(interfaceC0767h);
    }

    public static z0 c() {
        return new z0(null);
    }

    public static J d(D d5, I3.p pVar) {
        C0768i c0768i = C0768i.f6945a;
        E e4 = E.f1571a;
        InterfaceC0767h interfaceC0767hT = t(d5, c0768i);
        E e5 = E.f1571a;
        J j4 = new J(interfaceC0767hT, true, true);
        j4.e0(e4, j4, pVar);
        return j4;
    }

    /* JADX WARN: Multi-variable type inference failed */
    public static final Object e(I[] iArr, A3.j jVar) {
        if (iArr.length == 0) {
            return x3.p.f6784a;
        }
        C0125e c0125e = new C0125e(iArr);
        C0141m c0141m = new C0141m(1, e1.k.w(jVar));
        c0141m.r();
        int length = iArr.length;
        C0121c[] c0121cArr = new C0121c[length];
        for (int i4 = 0; i4 < length; i4++) {
            r rVar = iArr[i4];
            ((q0) rVar).g();
            C0121c c0121c = new C0121c(c0125e, c0141m);
            c0121c.f1616f = p(rVar, true, c0121c);
            c0121cArr[i4] = c0121c;
        }
        C0123d c0123d = new C0123d(c0121cArr);
        for (int i5 = 0; i5 < length; i5++) {
            C0121c c0121c2 = c0121cArr[i5];
            c0121c2.getClass();
            C0121c.f1615n.set(c0121c2, c0123d);
        }
        if (C0141m.f1639m.get(c0141m) instanceof v0) {
            c0141m.u(c0123d);
        } else {
            c0123d.b();
        }
        Object objQ = c0141m.q();
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        return objQ;
    }

    public static void f(D d5) {
        InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) d5.n().i(B.f1565b);
        if (interfaceC0132h0 != null) {
            interfaceC0132h0.a(null);
        } else {
            throw new IllegalStateException(("Scope cannot be cancelled because it does not have a job: " + d5).toString());
        }
    }

    public static final Object g(I3.p pVar, InterfaceC0762c interfaceC0762c) throws Throwable {
        V3.r rVar = new V3.r(interfaceC0762c, interfaceC0762c.getContext());
        Object objF0 = H0.a.f0(rVar, true, rVar, pVar);
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        return objF0;
    }

    public static final Object h(long j4, A3.j jVar) {
        w3.i iVar = w3.i.f6729a;
        if (j4 > 0) {
            C0141m c0141m = new C0141m(1, e1.k.w(jVar));
            c0141m.r();
            if (j4 < Long.MAX_VALUE) {
                k(c0141m.e).o(j4, c0141m);
            }
            Object objQ = c0141m.q();
            if (objQ == EnumC0789a.f6999a) {
                return objQ;
            }
        }
        return iVar;
    }

    public static final void i(InterfaceC0767h interfaceC0767h) {
        InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) interfaceC0767h.i(B.f1565b);
        if (interfaceC0132h0 != null && !interfaceC0132h0.b()) {
            throw interfaceC0132h0.f();
        }
    }

    public static final InterfaceC0767h j(InterfaceC0767h interfaceC0767h, InterfaceC0767h interfaceC0767h2, boolean z4) {
        Boolean bool = Boolean.FALSE;
        boolean zBooleanValue = ((Boolean) interfaceC0767h.h(bool, new C0151x(0))).booleanValue();
        boolean zBooleanValue2 = ((Boolean) interfaceC0767h2.h(bool, new C0151x(0))).booleanValue();
        if (!zBooleanValue && !zBooleanValue2) {
            return interfaceC0767h.s(interfaceC0767h2);
        }
        C0768i c0768i = C0768i.f6945a;
        InterfaceC0767h interfaceC0767h3 = (InterfaceC0767h) interfaceC0767h.h(c0768i, new C0151x(1));
        Object objH = interfaceC0767h2;
        if (zBooleanValue2) {
            objH = interfaceC0767h2.h(c0768i, new C0151x(2));
        }
        return interfaceC0767h3.s((InterfaceC0767h) objH);
    }

    public static final K k(InterfaceC0767h interfaceC0767h) {
        InterfaceC0765f interfaceC0765fI = interfaceC0767h.i(C0763d.f6944a);
        K k4 = interfaceC0765fI instanceof K ? (K) interfaceC0765fI : null;
        return k4 == null ? H.f1590a : k4;
    }

    public static final String l(Object obj) {
        return Integer.toHexString(System.identityHashCode(obj));
    }

    public static final InterfaceC0132h0 m(InterfaceC0767h interfaceC0767h) {
        InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) interfaceC0767h.i(B.f1565b);
        if (interfaceC0132h0 != null) {
            return interfaceC0132h0;
        }
        throw new IllegalStateException(("Current context doesn't contain Job in it: " + interfaceC0767h).toString());
    }

    public static final C0141m n(InterfaceC0762c interfaceC0762c) {
        C0141m c0141m;
        C0141m c0141m2;
        if (!(interfaceC0762c instanceof V3.g)) {
            return new C0141m(1, interfaceC0762c);
        }
        V3.g gVar = (V3.g) interfaceC0762c;
        loop0: while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = V3.g.f2223n;
            Object obj = atomicReferenceFieldUpdater.get(gVar);
            C0779j c0779j = V3.b.f2214c;
            c0141m = null;
            if (obj == null) {
                atomicReferenceFieldUpdater.set(gVar, c0779j);
                c0141m2 = null;
                break;
            }
            if (obj instanceof C0141m) {
                while (!atomicReferenceFieldUpdater.compareAndSet(gVar, obj, c0779j)) {
                    if (atomicReferenceFieldUpdater.get(gVar) != obj) {
                        break;
                    }
                }
                c0141m2 = (C0141m) obj;
                break loop0;
            }
            if (obj != c0779j && !(obj instanceof Throwable)) {
                throw new IllegalStateException(("Inconsistent state " + obj).toString());
            }
        }
        if (c0141m2 != null) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = C0141m.f1639m;
            Object obj2 = atomicReferenceFieldUpdater2.get(c0141m2);
            if (!(obj2 instanceof C0148u) || ((C0148u) obj2).f1663d == null) {
                C0141m.f1638f.set(c0141m2, 536870911);
                atomicReferenceFieldUpdater2.set(c0141m2, C0119b.f1613a);
                c0141m = c0141m2;
            } else {
                c0141m2.m();
            }
            if (c0141m != null) {
                return c0141m;
            }
        }
        return new C0141m(2, interfaceC0762c);
    }

    public static final void o(Throwable th, InterfaceC0767h interfaceC0767h) throws IllegalAccessException, InvocationTargetException {
        if (th instanceof L) {
            th = ((L) th).f1593a;
        }
        try {
            R3.b bVar = (R3.b) interfaceC0767h.i(B.f1564a);
            if (bVar != null) {
                bVar.A(th);
            } else {
                V3.b.d(th, interfaceC0767h);
            }
        } catch (Throwable th2) {
            if (th != th2) {
                RuntimeException runtimeException = new RuntimeException("Exception while trying to handle coroutine exception", th2);
                e1.k.b(runtimeException, th);
                th = runtimeException;
            }
            V3.b.d(th, interfaceC0767h);
        }
    }

    public static final Q p(InterfaceC0132h0 interfaceC0132h0, boolean z4, AbstractC0140l0 abstractC0140l0) {
        return interfaceC0132h0 instanceof q0 ? ((q0) interfaceC0132h0).M(z4, abstractC0140l0) : interfaceC0132h0.x(abstractC0140l0.m(), z4, new C0138k0(1, abstractC0140l0, AbstractC0140l0.class, "invoke", "invoke(Ljava/lang/Throwable;)V", 0));
    }

    public static final boolean q(D d5) {
        InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) d5.n().i(B.f1565b);
        if (interfaceC0132h0 != null) {
            return interfaceC0132h0.b();
        }
        return true;
    }

    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object r(java.util.List r4, A3.c r5) {
        /*
            boolean r0 = r5 instanceof Q3.C0127f
            if (r0 == 0) goto L13
            r0 = r5
            Q3.f r0 = (Q3.C0127f) r0
            int r1 = r0.f1625c
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f1625c = r1
            goto L18
        L13:
            Q3.f r0 = new Q3.f
            r0.<init>(r5)
        L18:
            java.lang.Object r5 = r0.f1624b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f1625c
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            java.util.Iterator r4 = r0.f1623a
            e1.AbstractC0367g.M(r5)
            goto L38
        L29:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "call to 'resume' before 'invoke' with coroutine"
            r4.<init>(r5)
            throw r4
        L31:
            e1.AbstractC0367g.M(r5)
            java.util.Iterator r4 = r4.iterator()
        L38:
            boolean r5 = r4.hasNext()
            if (r5 == 0) goto L4f
            java.lang.Object r5 = r4.next()
            Q3.h0 r5 = (Q3.InterfaceC0132h0) r5
            r0.f1623a = r4
            r0.f1625c = r3
            java.lang.Object r5 = r5.y(r0)
            if (r5 != r1) goto L38
            return r1
        L4f:
            w3.i r4 = w3.i.f6729a
            return r4
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.F.r(java.util.List, A3.c):java.lang.Object");
    }

    public static y0 s(D d5, InterfaceC0767h interfaceC0767h, I3.p pVar, int i4) {
        if ((i4 & 1) != 0) {
            interfaceC0767h = C0768i.f6945a;
        }
        E e4 = E.f1571a;
        InterfaceC0767h interfaceC0767hT = t(d5, interfaceC0767h);
        E e5 = E.f1571a;
        y0 y0Var = new y0(interfaceC0767hT, true, true);
        y0Var.e0(e4, y0Var, pVar);
        return y0Var;
    }

    public static final InterfaceC0767h t(D d5, InterfaceC0767h interfaceC0767h) {
        InterfaceC0767h interfaceC0767hJ = j(d5.n(), interfaceC0767h, true);
        X3.e eVar = O.f1596a;
        return (interfaceC0767hJ == eVar || interfaceC0767hJ.i(C0763d.f6944a) != null) ? interfaceC0767hJ : interfaceC0767hJ.s(eVar);
    }

    public static final Object u(Object obj) {
        return obj instanceof C0149v ? AbstractC0367g.h(((C0149v) obj).f1666a) : obj;
    }

    public static final void v(C0141m c0141m, InterfaceC0762c interfaceC0762c, boolean z4) {
        Object obj = C0141m.f1639m.get(c0141m);
        Throwable thD = c0141m.d(obj);
        Object objH = thD != null ? AbstractC0367g.h(thD) : c0141m.f(obj);
        if (!z4) {
            interfaceC0762c.resumeWith(objH);
            return;
        }
        J3.i.c(interfaceC0762c, "null cannot be cast to non-null type kotlinx.coroutines.internal.DispatchedContinuation<T of kotlinx.coroutines.DispatchedTaskKt.resume>");
        V3.g gVar = (V3.g) interfaceC0762c;
        A3.c cVar = gVar.e;
        InterfaceC0767h context = cVar.getContext();
        Object objN = V3.b.n(context, gVar.f2226m);
        I0 i0A = objN != V3.b.f2215d ? A(cVar, context, objN) : null;
        try {
            cVar.resumeWith(objH);
            if (i0A == null || i0A.g0()) {
                V3.b.g(context, objN);
            }
        } catch (Throwable th) {
            if (i0A == null || i0A.g0()) {
                V3.b.g(context, objN);
            }
            throw th;
        }
    }

    public static Object w(I3.p pVar) throws Throwable {
        long jI;
        C0768i c0768i = C0768i.f6945a;
        Thread threadCurrentThread = Thread.currentThread();
        C0763d c0763d = C0763d.f6944a;
        Z zA = B0.a();
        InterfaceC0767h interfaceC0767hJ = j(c0768i, zA, true);
        X3.e eVar = O.f1596a;
        if (interfaceC0767hJ != eVar && interfaceC0767hJ.i(c0763d) == null) {
            interfaceC0767hJ = interfaceC0767hJ.s(eVar);
        }
        C0129g c0129g = new C0129g(interfaceC0767hJ, threadCurrentThread, zA);
        c0129g.e0(E.f1571a, c0129g, pVar);
        Z z4 = c0129g.e;
        if (z4 != null) {
            int i4 = Z.f1609f;
            z4.H(false);
        }
        while (true) {
            if (z4 != null) {
                try {
                    jI = z4.I();
                } catch (Throwable th) {
                    if (z4 != null) {
                        int i5 = Z.f1609f;
                        z4.E(false);
                    }
                    throw th;
                }
            } else {
                jI = Long.MAX_VALUE;
            }
            if (c0129g.l()) {
                break;
            }
            LockSupport.parkNanos(c0129g, jI);
            if (Thread.interrupted()) {
                c0129g.u(new InterruptedException());
            }
        }
        if (z4 != null) {
            int i6 = Z.f1609f;
            z4.E(false);
        }
        Object objZ = z(q0.f1656a.get(c0129g));
        C0149v c0149v = objZ instanceof C0149v ? (C0149v) objZ : null;
        if (c0149v == null) {
            return objZ;
        }
        throw c0149v.f1666a;
    }

    public static final Object x(F0 f02, I3.p pVar) {
        p(f02, true, new S(k(f02.f2246d.getContext()).n(f02.e, f02, f02.f1612c), 0));
        return H0.a.f0(f02, false, f02, pVar);
    }

    public static final String y(InterfaceC0762c interfaceC0762c) {
        Object objH;
        if (interfaceC0762c instanceof V3.g) {
            return ((V3.g) interfaceC0762c).toString();
        }
        try {
            objH = interfaceC0762c + '@' + l(interfaceC0762c);
        } catch (Throwable th) {
            objH = AbstractC0367g.h(th);
        }
        if (w3.e.a(objH) != null) {
            objH = interfaceC0762c.getClass().getName() + '@' + l(interfaceC0762c);
        }
        return (String) objH;
    }

    public static final Object z(Object obj) {
        InterfaceC0124d0 interfaceC0124d0;
        C0126e0 c0126e0 = obj instanceof C0126e0 ? (C0126e0) obj : null;
        return (c0126e0 == null || (interfaceC0124d0 = c0126e0.f1622a) == null) ? obj : interfaceC0124d0;
    }
}
