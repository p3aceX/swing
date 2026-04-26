package Q3;

import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.CancellationException;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0765f;
import y3.InterfaceC0766g;
import y3.InterfaceC0767h;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public class q0 implements InterfaceC0132h0, w0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1656a = AtomicReferenceFieldUpdater.newUpdater(q0.class, Object.class, "_state$volatile");

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1657b = AtomicReferenceFieldUpdater.newUpdater(q0.class, Object.class, "_parentHandle$volatile");
    private volatile /* synthetic */ Object _parentHandle$volatile;
    private volatile /* synthetic */ Object _state$volatile;

    public q0(boolean z4) {
        this._state$volatile = z4 ? F.f1584j : F.f1583i;
    }

    public static C0145q R(V3.k kVar) {
        while (kVar.k()) {
            V3.k kVarG = kVar.g();
            if (kVarG == null) {
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = V3.k.f2234b;
                Object obj = atomicReferenceFieldUpdater.get(kVar);
                while (true) {
                    kVar = (V3.k) obj;
                    if (!kVar.k()) {
                        break;
                    }
                    obj = atomicReferenceFieldUpdater.get(kVar);
                }
            } else {
                kVar = kVarG;
            }
        }
        while (true) {
            kVar = kVar.i();
            if (!kVar.k()) {
                if (kVar instanceof C0145q) {
                    return (C0145q) kVar;
                }
                if (kVar instanceof s0) {
                    return null;
                }
            }
        }
    }

    public static String Z(Object obj) {
        if (!(obj instanceof o0)) {
            return obj instanceof InterfaceC0124d0 ? ((InterfaceC0124d0) obj).b() ? "Active" : "New" : obj instanceof C0149v ? "Cancelled" : "Completed";
        }
        o0 o0Var = (o0) obj;
        return o0Var.e() ? "Cancelling" : o0.f1648b.get(o0Var) == 1 ? "Completing" : "Active";
    }

    public String A() {
        return "Job was cancelled";
    }

    public boolean B(Throwable th) {
        if (th instanceof CancellationException) {
            return true;
        }
        return u(th) && G();
    }

    public final void C(InterfaceC0124d0 interfaceC0124d0, Object obj) throws IllegalAccessException, InvocationTargetException {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1657b;
        InterfaceC0144p interfaceC0144p = (InterfaceC0144p) atomicReferenceFieldUpdater.get(this);
        if (interfaceC0144p != null) {
            interfaceC0144p.a();
            atomicReferenceFieldUpdater.set(this, u0.f1664a);
        }
        A0.b bVar = null;
        C0149v c0149v = obj instanceof C0149v ? (C0149v) obj : null;
        Throwable th = c0149v != null ? c0149v.f1666a : null;
        if (interfaceC0124d0 instanceof AbstractC0140l0) {
            try {
                ((AbstractC0140l0) interfaceC0124d0).n(th);
                return;
            } catch (Throwable th2) {
                K(new A0.b("Exception in completion handler " + interfaceC0124d0 + " for " + this, th2));
                return;
            }
        }
        s0 s0VarD = interfaceC0124d0.d();
        if (s0VarD != null) {
            s0VarD.f(new V3.i(1), 1);
            Object obj2 = V3.k.f2233a.get(s0VarD);
            J3.i.c(obj2, "null cannot be cast to non-null type kotlinx.coroutines.internal.LockFreeLinkedListNode");
            for (V3.k kVarI = (V3.k) obj2; !kVarI.equals(s0VarD); kVarI = kVarI.i()) {
                if (kVarI instanceof AbstractC0140l0) {
                    try {
                        ((AbstractC0140l0) kVarI).n(th);
                    } catch (Throwable th3) {
                        if (bVar != null) {
                            e1.k.b(bVar, th3);
                        } else {
                            bVar = new A0.b("Exception in completion handler " + kVarI + " for " + this, th3);
                        }
                    }
                }
            }
            if (bVar != null) {
                K(bVar);
            }
        }
    }

    public final Throwable D(Object obj) {
        Throwable thC;
        if (obj instanceof Throwable) {
            return (Throwable) obj;
        }
        q0 q0Var = (q0) ((w0) obj);
        Object obj2 = f1656a.get(q0Var);
        if (obj2 instanceof o0) {
            thC = ((o0) obj2).c();
        } else if (obj2 instanceof C0149v) {
            thC = ((C0149v) obj2).f1666a;
        } else {
            if (obj2 instanceof InterfaceC0124d0) {
                throw new IllegalStateException(("Cannot be cancelling child in this state: " + obj2).toString());
            }
            thC = null;
        }
        CancellationException cancellationException = thC instanceof CancellationException ? (CancellationException) thC : null;
        return cancellationException == null ? new C0134i0("Parent job is ".concat(Z(obj2)), thC, q0Var) : cancellationException;
    }

    public final Object E(o0 o0Var, Object obj) throws IllegalAccessException, InvocationTargetException {
        boolean zE;
        Throwable thF;
        C0149v c0149v = obj instanceof C0149v ? (C0149v) obj : null;
        Throwable th = c0149v != null ? c0149v.f1666a : null;
        synchronized (o0Var) {
            zE = o0Var.e();
            ArrayList<Throwable> arrayListF = o0Var.f(th);
            thF = F(o0Var, arrayListF);
            if (thF != null && arrayListF.size() > 1) {
                Set setNewSetFromMap = Collections.newSetFromMap(new IdentityHashMap(arrayListF.size()));
                for (Throwable th2 : arrayListF) {
                    if (th2 != thF && th2 != thF && !(th2 instanceof CancellationException) && setNewSetFromMap.add(th2)) {
                        e1.k.b(thF, th2);
                    }
                }
            }
        }
        if (thF != null && thF != th) {
            obj = new C0149v(thF, false);
        }
        if (thF != null && (w(thF) || J(thF))) {
            J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.CompletedExceptionally");
            C0149v.f1665b.compareAndSet((C0149v) obj, 0, 1);
        }
        if (!zE) {
            T(thF);
        }
        U(obj);
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1656a;
        Object c0126e0 = obj instanceof InterfaceC0124d0 ? new C0126e0((InterfaceC0124d0) obj) : obj;
        while (!atomicReferenceFieldUpdater.compareAndSet(this, o0Var, c0126e0) && atomicReferenceFieldUpdater.get(this) == o0Var) {
        }
        C(o0Var, obj);
        return obj;
    }

    public final Throwable F(o0 o0Var, ArrayList arrayList) {
        Object next;
        Object obj = null;
        if (arrayList.isEmpty()) {
            if (o0Var.e()) {
                return new C0134i0(A(), null, this);
            }
            return null;
        }
        Iterator it = arrayList.iterator();
        while (true) {
            if (!it.hasNext()) {
                next = null;
                break;
            }
            next = it.next();
            if (!(((Throwable) next) instanceof CancellationException)) {
                break;
            }
        }
        Throwable th = (Throwable) next;
        if (th != null) {
            return th;
        }
        Throwable th2 = (Throwable) arrayList.get(0);
        if (th2 instanceof E0) {
            Iterator it2 = arrayList.iterator();
            while (true) {
                if (!it2.hasNext()) {
                    break;
                }
                Object next2 = it2.next();
                Throwable th3 = (Throwable) next2;
                if (th3 != th2 && (th3 instanceof E0)) {
                    obj = next2;
                    break;
                }
            }
            Throwable th4 = (Throwable) obj;
            if (th4 != null) {
                return th4;
            }
        }
        return th2;
    }

    public boolean G() {
        return true;
    }

    public boolean H() {
        return this instanceof C0146s;
    }

    public final s0 I(InterfaceC0124d0 interfaceC0124d0) {
        s0 s0VarD = interfaceC0124d0.d();
        if (s0VarD != null) {
            return s0VarD;
        }
        if (interfaceC0124d0 instanceof T) {
            return new s0();
        }
        if (interfaceC0124d0 instanceof AbstractC0140l0) {
            X((AbstractC0140l0) interfaceC0124d0);
            return null;
        }
        throw new IllegalStateException(("State should have list: " + interfaceC0124d0).toString());
    }

    public boolean J(Throwable th) {
        return false;
    }

    public final void L(InterfaceC0132h0 interfaceC0132h0) {
        u0 u0Var = u0.f1664a;
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1657b;
        if (interfaceC0132h0 == null) {
            atomicReferenceFieldUpdater.set(this, u0Var);
            return;
        }
        interfaceC0132h0.g();
        InterfaceC0144p interfaceC0144pZ = interfaceC0132h0.z(this);
        atomicReferenceFieldUpdater.set(this, interfaceC0144pZ);
        if (l()) {
            interfaceC0144pZ.a();
            atomicReferenceFieldUpdater.set(this, u0Var);
        }
    }

    public final Q M(boolean z4, AbstractC0140l0 abstractC0140l0) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        u0 u0Var;
        boolean z5;
        boolean zF;
        abstractC0140l0.f1637d = this;
        loop0: while (true) {
            atomicReferenceFieldUpdater = f1656a;
            Object obj = atomicReferenceFieldUpdater.get(this);
            boolean z6 = obj instanceof T;
            u0Var = u0.f1664a;
            z5 = true;
            if (!z6) {
                if (!(obj instanceof InterfaceC0124d0)) {
                    z5 = false;
                    break;
                }
                InterfaceC0124d0 interfaceC0124d0 = (InterfaceC0124d0) obj;
                s0 s0VarD = interfaceC0124d0.d();
                if (s0VarD == null) {
                    J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.JobNode");
                    X((AbstractC0140l0) obj);
                } else {
                    if (abstractC0140l0.m()) {
                        o0 o0Var = interfaceC0124d0 instanceof o0 ? (o0) interfaceC0124d0 : null;
                        Throwable thC = o0Var != null ? o0Var.c() : null;
                        if (thC == null) {
                            zF = s0VarD.f(abstractC0140l0, 5);
                        } else if (z4) {
                            abstractC0140l0.n(thC);
                            return u0Var;
                        }
                    } else {
                        zF = s0VarD.f(abstractC0140l0, 1);
                    }
                    if (zF) {
                        break;
                    }
                }
            } else {
                T t4 = (T) obj;
                if (t4.f1599a) {
                    while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, abstractC0140l0)) {
                        if (atomicReferenceFieldUpdater.get(this) != obj) {
                            break;
                        }
                    }
                    break loop0;
                }
                W(t4);
            }
        }
        if (z5) {
            return abstractC0140l0;
        }
        if (z4) {
            Object obj2 = atomicReferenceFieldUpdater.get(this);
            C0149v c0149v = obj2 instanceof C0149v ? (C0149v) obj2 : null;
            abstractC0140l0.n(c0149v != null ? c0149v.f1666a : null);
        }
        return u0Var;
    }

    public boolean N() {
        return this instanceof C0129g;
    }

    public final boolean O(Object obj) {
        Object objA0;
        do {
            objA0 = a0(f1656a.get(this), obj);
            if (objA0 == F.f1579d) {
                return false;
            }
            if (objA0 == F.e) {
                return true;
            }
        } while (objA0 == F.f1580f);
        r(objA0);
        return true;
    }

    public final Object P(Object obj) {
        Object objA0;
        do {
            objA0 = a0(f1656a.get(this), obj);
            if (objA0 == F.f1579d) {
                String str = "Job " + this + " is already complete or completing, but is being completed with " + obj;
                C0149v c0149v = obj instanceof C0149v ? (C0149v) obj : null;
                throw new IllegalStateException(str, c0149v != null ? c0149v.f1666a : null);
            }
        } while (objA0 == F.f1580f);
        return objA0;
    }

    public String Q() {
        return getClass().getSimpleName();
    }

    public final void S(s0 s0Var, Throwable th) throws IllegalAccessException, InvocationTargetException {
        T(th);
        s0Var.f(new V3.i(4), 4);
        Object obj = V3.k.f2233a.get(s0Var);
        J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.internal.LockFreeLinkedListNode");
        A0.b bVar = null;
        for (V3.k kVarI = (V3.k) obj; !kVarI.equals(s0Var); kVarI = kVarI.i()) {
            if ((kVarI instanceof AbstractC0140l0) && ((AbstractC0140l0) kVarI).m()) {
                try {
                    ((AbstractC0140l0) kVarI).n(th);
                } catch (Throwable th2) {
                    if (bVar != null) {
                        e1.k.b(bVar, th2);
                    } else {
                        bVar = new A0.b("Exception in completion handler " + kVarI + " for " + this, th2);
                    }
                }
            }
        }
        if (bVar != null) {
            K(bVar);
        }
        w(th);
    }

    public final void W(T t4) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        s0 s0Var = new s0();
        Object c0122c0 = s0Var;
        if (!t4.f1599a) {
            c0122c0 = new C0122c0(s0Var);
        }
        do {
            atomicReferenceFieldUpdater = f1656a;
            if (atomicReferenceFieldUpdater.compareAndSet(this, t4, c0122c0)) {
                return;
            }
        } while (atomicReferenceFieldUpdater.get(this) == t4);
    }

    public final void X(AbstractC0140l0 abstractC0140l0) {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        s0 s0Var = new s0();
        abstractC0140l0.getClass();
        V3.k.f2234b.set(s0Var, abstractC0140l0);
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = V3.k.f2233a;
        atomicReferenceFieldUpdater2.set(s0Var, abstractC0140l0);
        loop0: while (true) {
            if (atomicReferenceFieldUpdater2.get(abstractC0140l0) == abstractC0140l0) {
                while (!atomicReferenceFieldUpdater2.compareAndSet(abstractC0140l0, abstractC0140l0, s0Var)) {
                    if (atomicReferenceFieldUpdater2.get(abstractC0140l0) != abstractC0140l0) {
                        break;
                    }
                }
                s0Var.h(abstractC0140l0);
                break loop0;
            }
            break;
        }
        V3.k kVarI = abstractC0140l0.i();
        do {
            atomicReferenceFieldUpdater = f1656a;
            if (atomicReferenceFieldUpdater.compareAndSet(this, abstractC0140l0, kVarI)) {
                return;
            }
        } while (atomicReferenceFieldUpdater.get(this) == abstractC0140l0);
    }

    public final int Y(Object obj) {
        boolean z4 = obj instanceof T;
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1656a;
        if (z4) {
            if (((T) obj).f1599a) {
                return 0;
            }
            T t4 = F.f1584j;
            while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, t4)) {
                if (atomicReferenceFieldUpdater.get(this) != obj) {
                    return -1;
                }
            }
            V();
            return 1;
        }
        if (!(obj instanceof C0122c0)) {
            return 0;
        }
        s0 s0Var = ((C0122c0) obj).f1618a;
        while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, s0Var)) {
            if (atomicReferenceFieldUpdater.get(this) != obj) {
                return -1;
            }
        }
        V();
        return 1;
    }

    @Override // Q3.InterfaceC0132h0
    public void a(CancellationException cancellationException) {
        if (cancellationException == null) {
            cancellationException = new C0134i0(A(), null, this);
        }
        v(cancellationException);
    }

    public final Object a0(Object obj, Object obj2) throws IllegalAccessException, InvocationTargetException {
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater;
        if (!(obj instanceof InterfaceC0124d0)) {
            return F.f1579d;
        }
        if (((obj instanceof T) || (obj instanceof AbstractC0140l0)) && !(obj instanceof C0145q) && !(obj2 instanceof C0149v)) {
            InterfaceC0124d0 interfaceC0124d0 = (InterfaceC0124d0) obj;
            Object c0126e0 = obj2 instanceof InterfaceC0124d0 ? new C0126e0((InterfaceC0124d0) obj2) : obj2;
            do {
                atomicReferenceFieldUpdater = f1656a;
                if (atomicReferenceFieldUpdater.compareAndSet(this, interfaceC0124d0, c0126e0)) {
                    T(null);
                    U(obj2);
                    C(interfaceC0124d0, obj2);
                    return obj2;
                }
            } while (atomicReferenceFieldUpdater.get(this) == interfaceC0124d0);
            return F.f1580f;
        }
        InterfaceC0124d0 interfaceC0124d02 = (InterfaceC0124d0) obj;
        s0 s0VarI = I(interfaceC0124d02);
        if (s0VarI == null) {
            return F.f1580f;
        }
        o0 o0Var = interfaceC0124d02 instanceof o0 ? (o0) interfaceC0124d02 : null;
        if (o0Var == null) {
            o0Var = new o0(s0VarI, null);
        }
        synchronized (o0Var) {
            try {
                AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = o0.f1648b;
                if (atomicIntegerFieldUpdater.get(o0Var) == 1) {
                    return F.f1579d;
                }
                atomicIntegerFieldUpdater.set(o0Var, 1);
                if (o0Var != interfaceC0124d02) {
                    AtomicReferenceFieldUpdater atomicReferenceFieldUpdater2 = f1656a;
                    while (!atomicReferenceFieldUpdater2.compareAndSet(this, interfaceC0124d02, o0Var)) {
                        if (atomicReferenceFieldUpdater2.get(this) != interfaceC0124d02) {
                            return F.f1580f;
                        }
                    }
                }
                boolean zE = o0Var.e();
                C0149v c0149v = obj2 instanceof C0149v ? (C0149v) obj2 : null;
                if (c0149v != null) {
                    o0Var.a(c0149v.f1666a);
                }
                Throwable thC = zE ? null : o0Var.c();
                if (thC != null) {
                    S(s0VarI, thC);
                }
                C0145q c0145qR = R(s0VarI);
                if (c0145qR != null && b0(o0Var, c0145qR, obj2)) {
                    return F.e;
                }
                s0VarI.f(new V3.i(2), 2);
                C0145q c0145qR2 = R(s0VarI);
                return (c0145qR2 == null || !b0(o0Var, c0145qR2, obj2)) ? E(o0Var, obj2) : F.e;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    @Override // Q3.InterfaceC0132h0
    public boolean b() {
        Object obj = f1656a.get(this);
        return (obj instanceof InterfaceC0124d0) && ((InterfaceC0124d0) obj).b();
    }

    public final boolean b0(o0 o0Var, C0145q c0145q, Object obj) {
        while (F.p(c0145q.e, false, new n0(this, o0Var, c0145q, obj)) == u0.f1664a) {
            c0145q = R(c0145q);
            if (c0145q == null) {
                return false;
            }
        }
        return true;
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h c(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.y(this, interfaceC0766g);
    }

    public Object d() throws Throwable {
        Object obj = f1656a.get(this);
        if (obj instanceof InterfaceC0124d0) {
            throw new IllegalStateException("This job has not completed yet");
        }
        if (obj instanceof C0149v) {
            throw ((C0149v) obj).f1666a;
        }
        return F.z(obj);
    }

    @Override // Q3.InterfaceC0132h0
    public final CancellationException f() {
        CancellationException c0134i0;
        Object obj = f1656a.get(this);
        if (!(obj instanceof o0)) {
            if (obj instanceof InterfaceC0124d0) {
                throw new IllegalStateException(("Job is still new or active: " + this).toString());
            }
            if (!(obj instanceof C0149v)) {
                return new C0134i0(getClass().getSimpleName().concat(" has completed normally"), null, this);
            }
            Throwable th = ((C0149v) obj).f1666a;
            c0134i0 = th instanceof CancellationException ? (CancellationException) th : null;
            return c0134i0 == null ? new C0134i0(A(), th, this) : c0134i0;
        }
        Throwable thC = ((o0) obj).c();
        if (thC == null) {
            throw new IllegalStateException(("Job is still new or active: " + this).toString());
        }
        String strConcat = getClass().getSimpleName().concat(" is cancelling");
        c0134i0 = thC instanceof CancellationException ? (CancellationException) thC : null;
        if (c0134i0 == null) {
            if (strConcat == null) {
                strConcat = A();
            }
            c0134i0 = new C0134i0(strConcat, thC, this);
        }
        return c0134i0;
    }

    @Override // Q3.InterfaceC0132h0
    public final boolean g() {
        int iY;
        do {
            iY = Y(f1656a.get(this));
            if (iY == 0) {
                return false;
            }
        } while (iY != 1);
        return true;
    }

    @Override // y3.InterfaceC0765f
    public final InterfaceC0766g getKey() {
        return B.f1565b;
    }

    @Override // y3.InterfaceC0767h
    public final Object h(Object obj, I3.p pVar) {
        return pVar.invoke(obj, this);
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0765f i(InterfaceC0766g interfaceC0766g) {
        return AbstractC0367g.u(this, interfaceC0766g);
    }

    @Override // Q3.InterfaceC0132h0
    public final boolean isCancelled() {
        Object obj = f1656a.get(this);
        if (obj instanceof C0149v) {
            return true;
        }
        return (obj instanceof o0) && ((o0) obj).e();
    }

    @Override // Q3.InterfaceC0132h0
    public final boolean l() {
        return !(f1656a.get(this) instanceof InterfaceC0124d0);
    }

    @Override // Q3.InterfaceC0132h0
    public final O3.c p() {
        return new O3.f(new p0(this, null), 0);
    }

    @Override // Q3.InterfaceC0132h0
    public final Q q(I3.l lVar) {
        return M(true, new S(lVar, 1));
    }

    @Override // y3.InterfaceC0767h
    public final InterfaceC0767h s(InterfaceC0767h interfaceC0767h) {
        return AbstractC0367g.A(this, interfaceC0767h);
    }

    public void t(Object obj) {
        r(obj);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Q() + '{' + Z(f1656a.get(this)) + '}');
        sb.append('@');
        sb.append(F.l(this));
        return sb.toString();
    }

    /* JADX WARN: Code restructure failed: missing block: B:31:0x006a, code lost:
    
        r0 = r10;
     */
    /* JADX WARN: Removed duplicated region for block: B:18:0x0041 A[PHI: r0
      0x0041: PHI (r0v1 java.lang.Object) = (r0v0 java.lang.Object), (r0v13 java.lang.Object) binds: [B:3:0x0008, B:16:0x003d] A[DONT_GENERATE, DONT_INLINE]] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean u(java.lang.Object r10) {
        /*
            Method dump skipped, instruction units count: 275
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: Q3.q0.u(java.lang.Object):boolean");
    }

    public void v(CancellationException cancellationException) {
        u(cancellationException);
    }

    public final boolean w(Throwable th) {
        if (N()) {
            return true;
        }
        boolean z4 = th instanceof CancellationException;
        InterfaceC0144p interfaceC0144p = (InterfaceC0144p) f1657b.get(this);
        return (interfaceC0144p == null || interfaceC0144p == u0.f1664a) ? z4 : interfaceC0144p.c(th) || z4;
    }

    @Override // Q3.InterfaceC0132h0
    public final Q x(boolean z4, boolean z5, C0138k0 c0138k0) {
        return M(z5, z4 ? new C0130g0(c0138k0) : new S(c0138k0, 1));
    }

    @Override // Q3.InterfaceC0132h0
    public final Object y(A3.c cVar) {
        Object obj;
        w3.i iVar;
        do {
            obj = f1656a.get(this);
            boolean z4 = obj instanceof InterfaceC0124d0;
            iVar = w3.i.f6729a;
            if (!z4) {
                F.i(cVar.getContext());
                return iVar;
            }
        } while (Y(obj) < 0);
        C0141m c0141m = new C0141m(1, e1.k.w(cVar));
        c0141m.r();
        c0141m.u(new C0133i(F.p(this, true, new C0143o(c0141m, 1)), 2));
        Object objQ = c0141m.q();
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        if (objQ != enumC0789a) {
            objQ = iVar;
        }
        return objQ == enumC0789a ? objQ : iVar;
    }

    @Override // Q3.InterfaceC0132h0
    public final InterfaceC0144p z(q0 q0Var) {
        C0145q c0145q = new C0145q(q0Var);
        c0145q.f1637d = this;
        loop0: while (true) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f1656a;
            Object obj = atomicReferenceFieldUpdater.get(this);
            if (obj instanceof T) {
                T t4 = (T) obj;
                if (t4.f1599a) {
                    while (!atomicReferenceFieldUpdater.compareAndSet(this, obj, c0145q)) {
                        if (atomicReferenceFieldUpdater.get(this) != obj) {
                            break;
                        }
                    }
                    break loop0;
                }
                W(t4);
            } else {
                boolean z4 = obj instanceof InterfaceC0124d0;
                u0 u0Var = u0.f1664a;
                if (!z4) {
                    Object obj2 = atomicReferenceFieldUpdater.get(this);
                    C0149v c0149v = obj2 instanceof C0149v ? (C0149v) obj2 : null;
                    c0145q.n(c0149v != null ? c0149v.f1666a : null);
                    return u0Var;
                }
                s0 s0VarD = ((InterfaceC0124d0) obj).d();
                if (s0VarD == null) {
                    J3.i.c(obj, "null cannot be cast to non-null type kotlinx.coroutines.JobNode");
                    X((AbstractC0140l0) obj);
                } else if (!s0VarD.f(c0145q, 7)) {
                    boolean zF = s0VarD.f(c0145q, 3);
                    Object obj3 = atomicReferenceFieldUpdater.get(this);
                    if (obj3 instanceof o0) {
                        thC = ((o0) obj3).c();
                    } else {
                        C0149v c0149v2 = obj3 instanceof C0149v ? (C0149v) obj3 : null;
                        if (c0149v2 != null) {
                            thC = c0149v2.f1666a;
                        }
                    }
                    c0145q.n(thC);
                    if (zF) {
                        break loop0;
                    }
                    return u0Var;
                }
            }
        }
        return c0145q;
    }

    public void V() {
    }

    public void K(A0.b bVar) {
        throw bVar;
    }

    public void T(Throwable th) {
    }

    public void U(Object obj) {
    }

    public void r(Object obj) {
    }
}
