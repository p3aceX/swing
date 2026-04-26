package V3;

import Q3.A;
import Q3.A0;
import Q3.C0151x;
import Q3.L;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0767h;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0779j f2213b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0779j f2214c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0779j f2212a = new C0779j("CLOSED", 20);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0779j f2215d = new C0779j("NO_THREAD_ELEMENTS", 20);
    public static final C0151x e = new C0151x(4);

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final C0151x f2216f = new C0151x(5);

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final C0151x f2217g = new C0151x(6);

    static {
        int i4 = 20;
        f2213b = new C0779j("UNDEFINED", i4);
        f2214c = new C0779j("REUSABLE_CLAIMED", i4);
    }

    public static final void a(int i4) {
        if (i4 < 1) {
            throw new IllegalArgumentException(S.d(i4, "Expected positive parallelism level, but got ").toString());
        }
    }

    public static final Object b(s sVar, long j4, I3.p pVar) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        while (true) {
            if (sVar.f2248c >= j4 && !sVar.d()) {
                return sVar;
            }
            Object obj = c.f2218a.get(sVar);
            C0779j c0779j = f2212a;
            if (obj == c0779j) {
                return c0779j;
            }
            s sVar2 = (s) ((c) obj);
            if (sVar2 == null) {
                sVar2 = (s) pVar.invoke(Long.valueOf(sVar.f2248c + 1), sVar);
                do {
                    atomicReferenceFieldUpdater = c.f2218a;
                    if (atomicReferenceFieldUpdater.compareAndSet(sVar, null, sVar2)) {
                        if (sVar.d()) {
                            sVar.e();
                        }
                    }
                } while (atomicReferenceFieldUpdater.get(sVar) == null);
            }
            sVar = sVar2;
        }
    }

    public static final s c(Object obj) {
        if (obj != f2212a) {
            return (s) obj;
        }
        throw new IllegalStateException("Does not contain segment");
    }

    public static final void d(Throwable th, InterfaceC0767h interfaceC0767h) {
        Throwable runtimeException;
        Iterator it = e.f2221a.iterator();
        while (it.hasNext()) {
            try {
                ((R3.b) it.next()).A(th);
            } catch (Throwable th2) {
                if (th == th2) {
                    runtimeException = th;
                } else {
                    runtimeException = new RuntimeException("Exception while trying to handle coroutine exception", th2);
                    e1.k.b(runtimeException, th);
                }
                Thread threadCurrentThread = Thread.currentThread();
                threadCurrentThread.getUncaughtExceptionHandler().uncaughtException(threadCurrentThread, runtimeException);
            }
        }
        try {
            e1.k.b(th, new f(interfaceC0767h));
        } catch (Throwable unused) {
        }
        Thread threadCurrentThread2 = Thread.currentThread();
        threadCurrentThread2.getUncaughtExceptionHandler().uncaughtException(threadCurrentThread2, th);
    }

    public static final boolean e(Object obj) {
        return obj == f2212a;
    }

    public static final Object f(Object obj, Object obj2) {
        if (obj == null) {
            return obj2;
        }
        if (obj instanceof ArrayList) {
            ((ArrayList) obj).add(obj2);
            return obj;
        }
        ArrayList arrayList = new ArrayList(4);
        arrayList.add(obj);
        arrayList.add(obj2);
        return arrayList;
    }

    public static final void g(InterfaceC0767h interfaceC0767h, Object obj) {
        if (obj == f2215d) {
            return;
        }
        if (!(obj instanceof w)) {
            Object objH = interfaceC0767h.h(null, f2216f);
            J3.i.c(objH, "null cannot be cast to non-null type kotlinx.coroutines.ThreadContextElement<kotlin.Any?>");
            B1.a.p(objH);
            throw null;
        }
        w wVar = (w) obj;
        A0[] a0Arr = wVar.f2254b;
        int length = a0Arr.length - 1;
        if (length < 0) {
            return;
        }
        A0 a02 = a0Arr[length];
        J3.i.b(null);
        Object obj2 = wVar.f2253a[length];
        throw null;
    }

    /* JADX WARN: Removed duplicated region for block: B:32:0x008a A[Catch: all -> 0x0069, DONT_GENERATE, TryCatch #2 {all -> 0x0069, blocks: (B:16:0x0049, B:18:0x0057, B:20:0x005d, B:33:0x008d, B:23:0x006b, B:25:0x0079, B:30:0x0084, B:32:0x008a, B:38:0x009a, B:41:0x00a3, B:40:0x00a0, B:28:0x007f), top: B:54:0x0049, inners: #0 }] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final void h(java.lang.Object r9, y3.InterfaceC0762c r10) throws Q3.L {
        /*
            boolean r0 = r10 instanceof V3.g
            if (r0 == 0) goto Lae
            V3.g r10 = (V3.g) r10
            java.lang.Throwable r0 = w3.e.a(r9)
            if (r0 != 0) goto Le
            r1 = r9
            goto L14
        Le:
            Q3.v r1 = new Q3.v
            r2 = 0
            r1.<init>(r0, r2)
        L14:
            Q3.A r0 = r10.f2224d
            A3.c r2 = r10.e
            y3.h r3 = r2.getContext()
            boolean r3 = j(r0, r3)
            r4 = 1
            if (r3 == 0) goto L2f
            r10.f2225f = r1
            r10.f1595c = r4
            y3.h r9 = r2.getContext()
            i(r0, r9, r10)
            return
        L2f:
            Q3.Z r0 = Q3.B0.a()
            long r5 = r0.f1610c
            r7 = 4294967296(0x100000000, double:2.121995791E-314)
            int r3 = (r5 > r7 ? 1 : (r5 == r7 ? 0 : -1))
            if (r3 < 0) goto L46
            r10.f2225f = r1
            r10.f1595c = r4
            r0.F(r10)
            goto La8
        L46:
            r0.H(r4)
            y3.h r1 = r2.getContext()     // Catch: java.lang.Throwable -> L69
            Q3.B r3 = Q3.B.f1565b     // Catch: java.lang.Throwable -> L69
            y3.f r1 = r1.i(r3)     // Catch: java.lang.Throwable -> L69
            Q3.h0 r1 = (Q3.InterfaceC0132h0) r1     // Catch: java.lang.Throwable -> L69
            if (r1 == 0) goto L6b
            boolean r3 = r1.b()     // Catch: java.lang.Throwable -> L69
            if (r3 != 0) goto L6b
            java.util.concurrent.CancellationException r9 = r1.f()     // Catch: java.lang.Throwable -> L69
            w3.d r9 = e1.AbstractC0367g.h(r9)     // Catch: java.lang.Throwable -> L69
            r10.resumeWith(r9)     // Catch: java.lang.Throwable -> L69
            goto L8d
        L69:
            r9 = move-exception
            goto La4
        L6b:
            java.lang.Object r1 = r10.f2226m     // Catch: java.lang.Throwable -> L69
            y3.h r3 = r2.getContext()     // Catch: java.lang.Throwable -> L69
            java.lang.Object r1 = n(r3, r1)     // Catch: java.lang.Throwable -> L69
            z0.j r5 = V3.b.f2215d     // Catch: java.lang.Throwable -> L69
            if (r1 == r5) goto L7e
            Q3.I0 r5 = Q3.F.A(r2, r3, r1)     // Catch: java.lang.Throwable -> L69
            goto L7f
        L7e:
            r5 = 0
        L7f:
            r2.resumeWith(r9)     // Catch: java.lang.Throwable -> L97
            if (r5 == 0) goto L8a
            boolean r9 = r5.g0()     // Catch: java.lang.Throwable -> L69
            if (r9 == 0) goto L8d
        L8a:
            g(r3, r1)     // Catch: java.lang.Throwable -> L69
        L8d:
            boolean r9 = r0.J()     // Catch: java.lang.Throwable -> L69
            if (r9 != 0) goto L8d
        L93:
            r0.E(r4)
            goto La8
        L97:
            r9 = move-exception
            if (r5 == 0) goto La0
            boolean r2 = r5.g0()     // Catch: java.lang.Throwable -> L69
            if (r2 == 0) goto La3
        La0:
            g(r3, r1)     // Catch: java.lang.Throwable -> L69
        La3:
            throw r9     // Catch: java.lang.Throwable -> L69
        La4:
            r10.g(r9)     // Catch: java.lang.Throwable -> La9
            goto L93
        La8:
            return
        La9:
            r9 = move-exception
            r0.E(r4)
            throw r9
        Lae:
            r10.resumeWith(r9)
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: V3.b.h(java.lang.Object, y3.c):void");
    }

    public static final void i(A a5, InterfaceC0767h interfaceC0767h, Runnable runnable) throws L {
        try {
            a5.A(interfaceC0767h, runnable);
        } catch (Throwable th) {
            throw new L(th, a5, interfaceC0767h);
        }
    }

    public static final boolean j(A a5, InterfaceC0767h interfaceC0767h) throws L {
        try {
            return a5.C(interfaceC0767h);
        } catch (Throwable th) {
            throw new L(th, a5, interfaceC0767h);
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:31:0x0057  */
    /* JADX WARN: Removed duplicated region for block: B:48:0x0096  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final long k(java.lang.String r23, long r24, long r26, long r28) {
        /*
            Method dump skipped, instruction units count: 253
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: V3.b.k(java.lang.String, long, long, long):long");
    }

    public static int l(int i4, int i5, String str) {
        return (int) k(str, i4, 1, (i5 & 8) != 0 ? com.google.android.gms.common.api.f.API_PRIORITY_OTHER : 2097150);
    }

    public static final Object m(InterfaceC0767h interfaceC0767h) {
        Object objH = interfaceC0767h.h(0, e);
        J3.i.b(objH);
        return objH;
    }

    public static final Object n(InterfaceC0767h interfaceC0767h, Object obj) {
        if (obj == null) {
            obj = m(interfaceC0767h);
        }
        if (obj == 0) {
            return f2215d;
        }
        if (obj instanceof Integer) {
            return interfaceC0767h.h(new w(((Number) obj).intValue(), interfaceC0767h), f2217g);
        }
        B1.a.p(obj);
        throw null;
    }
}
