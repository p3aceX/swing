package R3;

import J3.i;
import O.RunnableC0093d;
import Q3.A;
import Q3.B;
import Q3.C0141m;
import Q3.F0;
import Q3.InterfaceC0132h0;
import Q3.K;
import Q3.O;
import Q3.Q;
import Q3.u0;
import V3.o;
import android.os.Handler;
import android.os.Looper;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.concurrent.CancellationException;
import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class d extends A implements K {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Handler f1714c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f1715d;
    public final d e;

    public d(Handler handler, boolean z4) {
        this.f1714c = handler;
        this.f1715d = z4;
        this.e = z4 ? this : new d(handler, true);
    }

    @Override // Q3.A
    public final void A(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        if (this.f1714c.post(runnable)) {
            return;
        }
        E(interfaceC0767h, runnable);
    }

    @Override // Q3.A
    public final boolean C(InterfaceC0767h interfaceC0767h) {
        return (this.f1715d && i.a(Looper.myLooper(), this.f1714c.getLooper())) ? false : true;
    }

    public final void E(InterfaceC0767h interfaceC0767h, Runnable runnable) {
        CancellationException cancellationException = new CancellationException("The task was rejected, the handler underlying the dispatcher '" + this + "' was closed");
        InterfaceC0132h0 interfaceC0132h0 = (InterfaceC0132h0) interfaceC0767h.i(B.f1565b);
        if (interfaceC0132h0 != null) {
            interfaceC0132h0.a(cancellationException);
        }
        X3.e eVar = O.f1596a;
        X3.d.f2437c.A(interfaceC0767h, runnable);
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof d)) {
            return false;
        }
        d dVar = (d) obj;
        return dVar.f1714c == this.f1714c && dVar.f1715d == this.f1715d;
    }

    public final int hashCode() {
        return System.identityHashCode(this.f1714c) ^ (this.f1715d ? 1231 : 1237);
    }

    @Override // Q3.K
    public final Q n(long j4, final F0 f02, InterfaceC0767h interfaceC0767h) {
        if (j4 > 4611686018427387903L) {
            j4 = 4611686018427387903L;
        }
        if (this.f1714c.postDelayed(f02, j4)) {
            return new Q() { // from class: R3.c
                @Override // Q3.Q
                public final void a() {
                    this.f1712a.f1714c.removeCallbacks(f02);
                }
            };
        }
        E(interfaceC0767h, f02);
        return u0.f1664a;
    }

    @Override // Q3.K
    public final void o(long j4, C0141m c0141m) {
        RunnableC0093d runnableC0093d = new RunnableC0093d(1, c0141m, this);
        if (j4 > 4611686018427387903L) {
            j4 = 4611686018427387903L;
        }
        if (this.f1714c.postDelayed(runnableC0093d, j4)) {
            c0141m.t(new M1.a(1, this, runnableC0093d));
        } else {
            E(c0141m.e, runnableC0093d);
        }
    }

    @Override // Q3.A
    public final String toString() {
        d dVar;
        String str;
        X3.e eVar = O.f1596a;
        d dVar2 = o.f2244a;
        if (this == dVar2) {
            str = "Dispatchers.Main";
        } else {
            try {
                dVar = dVar2.e;
            } catch (UnsupportedOperationException unused) {
                dVar = null;
            }
            str = this == dVar ? "Dispatchers.Main.immediate" : null;
        }
        if (str != null) {
            return str;
        }
        String string = this.f1714c.toString();
        return this.f1715d ? S.f(string, ".immediate") : string;
    }
}
