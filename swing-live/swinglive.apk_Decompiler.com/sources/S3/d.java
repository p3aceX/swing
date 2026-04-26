package S3;

import Q3.C0141m;
import Q3.F;
import Q3.K0;
import e1.AbstractC0367g;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import z0.C0779j;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class d implements K0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f1817a = g.f1844p;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0141m f1818b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ e f1819c;

    public d(e eVar) {
        this.f1819c = eVar;
    }

    @Override // Q3.K0
    public final void a(V3.s sVar, int i4) {
        C0141m c0141m = this.f1818b;
        if (c0141m != null) {
            c0141m.a(sVar, i4);
        }
    }

    public final Object b(A3.c cVar) throws Throwable {
        n nVarL;
        Boolean bool;
        Object obj = this.f1817a;
        boolean z4 = true;
        if (obj == g.f1844p || obj == g.f1840l) {
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = e.f1824m;
            e eVar = this.f1819c;
            n nVar = (n) atomicReferenceFieldUpdater.get(eVar);
            while (true) {
                eVar.getClass();
                if (eVar.s(e.f1820b.get(eVar), true)) {
                    this.f1817a = g.f1840l;
                    Throwable thN = eVar.n();
                    if (thN != null) {
                        int i4 = V3.t.f2249a;
                        throw thN;
                    }
                    z4 = false;
                } else {
                    long andIncrement = e.f1821c.getAndIncrement(eVar);
                    long j4 = g.f1831b;
                    long j5 = andIncrement / j4;
                    int i5 = (int) (andIncrement % j4);
                    if (nVar.f2248c != j5) {
                        nVarL = eVar.l(j5, nVar);
                        if (nVarL == null) {
                            continue;
                        }
                    } else {
                        nVarL = nVar;
                    }
                    Object objD = eVar.D(nVarL, i5, andIncrement, null);
                    C0779j c0779j = g.f1841m;
                    if (objD == c0779j) {
                        throw new IllegalStateException("unreachable");
                    }
                    C0779j c0779j2 = g.f1843o;
                    if (objD == c0779j2) {
                        if (andIncrement < eVar.q()) {
                            nVarL.b();
                        }
                        nVar = nVarL;
                    } else {
                        if (objD == g.f1842n) {
                            e eVar2 = this.f1819c;
                            C0141m c0141mN = F.n(e1.k.w(cVar));
                            try {
                                this.f1818b = c0141mN;
                                Object objD2 = eVar2.D(nVarL, i5, andIncrement, this);
                                if (objD2 == c0779j) {
                                    a(nVarL, i5);
                                } else {
                                    if (objD2 == c0779j2) {
                                        if (andIncrement < eVar2.q()) {
                                            nVarL.b();
                                        }
                                        n nVar2 = (n) e.f1824m.get(eVar2);
                                        while (true) {
                                            if (eVar2.s(e.f1820b.get(eVar2), true)) {
                                                C0141m c0141m = this.f1818b;
                                                J3.i.b(c0141m);
                                                this.f1818b = null;
                                                this.f1817a = g.f1840l;
                                                Throwable thN2 = eVar.n();
                                                if (thN2 == null) {
                                                    c0141m.resumeWith(Boolean.FALSE);
                                                } else {
                                                    c0141m.resumeWith(AbstractC0367g.h(thN2));
                                                }
                                            } else {
                                                long andIncrement2 = e.f1821c.getAndIncrement(eVar2);
                                                long j6 = g.f1831b;
                                                long j7 = andIncrement2 / j6;
                                                int i6 = (int) (andIncrement2 % j6);
                                                if (nVar2.f2248c != j7) {
                                                    n nVarL2 = eVar2.l(j7, nVar2);
                                                    if (nVarL2 != null) {
                                                        nVar2 = nVarL2;
                                                    }
                                                }
                                                Object objD3 = eVar2.D(nVar2, i6, andIncrement2, this);
                                                if (objD3 == g.f1841m) {
                                                    a(nVar2, i6);
                                                    break;
                                                }
                                                if (objD3 == g.f1843o) {
                                                    if (andIncrement2 < eVar2.q()) {
                                                        nVar2.b();
                                                    }
                                                } else {
                                                    if (objD3 == g.f1842n) {
                                                        throw new IllegalStateException("unexpected");
                                                    }
                                                    nVar2.b();
                                                    this.f1817a = objD3;
                                                    this.f1818b = null;
                                                    bool = Boolean.TRUE;
                                                }
                                            }
                                        }
                                    } else {
                                        nVarL.b();
                                        this.f1817a = objD2;
                                        this.f1818b = null;
                                        bool = Boolean.TRUE;
                                    }
                                    c0141mN.z(bool, null);
                                }
                                Object objQ = c0141mN.q();
                                EnumC0789a enumC0789a = EnumC0789a.f6999a;
                                return objQ;
                            } catch (Throwable th) {
                                c0141mN.y();
                                throw th;
                            }
                        }
                        nVarL.b();
                        this.f1817a = objD;
                    }
                }
            }
        }
        return Boolean.valueOf(z4);
    }

    public final Object c() throws Throwable {
        Object obj = this.f1817a;
        C0779j c0779j = g.f1844p;
        if (obj == c0779j) {
            throw new IllegalStateException("`hasNext()` has not been invoked");
        }
        this.f1817a = c0779j;
        if (obj != g.f1840l) {
            return obj;
        }
        Throwable thO = this.f1819c.o();
        int i4 = V3.t.f2249a;
        throw thO;
    }
}
