package V3;

import Q3.A;
import Q3.B0;
import Q3.C0149v;
import Q3.F;
import Q3.L;
import Q3.N;
import Q3.Z;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0762c;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class g extends N implements A3.d, InterfaceC0762c {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2223n = AtomicReferenceFieldUpdater.newUpdater(g.class, Object.class, "_reusableCancellableContinuation$volatile");
    private volatile /* synthetic */ Object _reusableCancellableContinuation$volatile;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final A f2224d;
    public final A3.c e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Object f2225f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final Object f2226m;

    public g(A a5, A3.c cVar) {
        super(-1);
        this.f2224d = a5;
        this.e = cVar;
        this.f2225f = b.f2213b;
        this.f2226m = b.m(cVar.getContext());
    }

    @Override // A3.d
    public final A3.d getCallerFrame() {
        return this.e;
    }

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        return this.e.getContext();
    }

    @Override // Q3.N
    public final Object h() {
        Object obj = this.f2225f;
        this.f2225f = b.f2213b;
        return obj;
    }

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) throws L {
        Throwable thA = w3.e.a(obj);
        Object c0149v = thA == null ? obj : new C0149v(thA, false);
        A3.c cVar = this.e;
        InterfaceC0767h context = cVar.getContext();
        A a5 = this.f2224d;
        if (b.j(a5, context)) {
            this.f2225f = c0149v;
            this.f1595c = 0;
            b.i(a5, cVar.getContext(), this);
            return;
        }
        Z zA = B0.a();
        if (zA.f1610c >= 4294967296L) {
            this.f2225f = c0149v;
            this.f1595c = 0;
            zA.F(this);
            return;
        }
        zA.H(true);
        try {
            InterfaceC0767h context2 = cVar.getContext();
            Object objN = b.n(context2, this.f2226m);
            try {
                cVar.resumeWith(obj);
                while (zA.J()) {
                }
            } finally {
                b.g(context2, objN);
            }
        } finally {
            try {
            } finally {
            }
        }
    }

    public final String toString() {
        return "DispatchedContinuation[" + this.f2224d + ", " + F.y(this.e) + ']';
    }

    @Override // Q3.N
    public final InterfaceC0762c c() {
        return this;
    }
}
