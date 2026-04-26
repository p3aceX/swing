package Q3;

import java.util.concurrent.CancellationException;

/* JADX INFO: renamed from: Q3.u, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0148u {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f1660a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final InterfaceC0135j f1661b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final I3.q f1662c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Object f1663d;
    public final Throwable e;

    public C0148u(Object obj, InterfaceC0135j interfaceC0135j, I3.q qVar, Object obj2, Throwable th) {
        this.f1660a = obj;
        this.f1661b = interfaceC0135j;
        this.f1662c = qVar;
        this.f1663d = obj2;
        this.e = th;
    }

    public static C0148u a(C0148u c0148u, InterfaceC0135j interfaceC0135j, CancellationException cancellationException, int i4) {
        Object obj = c0148u.f1660a;
        if ((i4 & 2) != 0) {
            interfaceC0135j = c0148u.f1661b;
        }
        InterfaceC0135j interfaceC0135j2 = interfaceC0135j;
        I3.q qVar = c0148u.f1662c;
        Object obj2 = c0148u.f1663d;
        Throwable th = cancellationException;
        if ((i4 & 16) != 0) {
            th = c0148u.e;
        }
        c0148u.getClass();
        return new C0148u(obj, interfaceC0135j2, qVar, obj2, th);
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof C0148u)) {
            return false;
        }
        C0148u c0148u = (C0148u) obj;
        return J3.i.a(this.f1660a, c0148u.f1660a) && J3.i.a(this.f1661b, c0148u.f1661b) && J3.i.a(this.f1662c, c0148u.f1662c) && J3.i.a(this.f1663d, c0148u.f1663d) && J3.i.a(this.e, c0148u.e);
    }

    public final int hashCode() {
        Object obj = this.f1660a;
        int iHashCode = (obj == null ? 0 : obj.hashCode()) * 31;
        InterfaceC0135j interfaceC0135j = this.f1661b;
        int iHashCode2 = (iHashCode + (interfaceC0135j == null ? 0 : interfaceC0135j.hashCode())) * 31;
        I3.q qVar = this.f1662c;
        int iHashCode3 = (iHashCode2 + (qVar == null ? 0 : qVar.hashCode())) * 31;
        Object obj2 = this.f1663d;
        int iHashCode4 = (iHashCode3 + (obj2 == null ? 0 : obj2.hashCode())) * 31;
        Throwable th = this.e;
        return iHashCode4 + (th != null ? th.hashCode() : 0);
    }

    public final String toString() {
        return "CompletedContinuation(result=" + this.f1660a + ", cancelHandler=" + this.f1661b + ", onCancellation=" + this.f1662c + ", idempotentResume=" + this.f1663d + ", cancelCause=" + this.e + ')';
    }

    public /* synthetic */ C0148u(Object obj, InterfaceC0135j interfaceC0135j, I3.q qVar, CancellationException cancellationException, int i4) {
        this(obj, (i4 & 2) != 0 ? null : interfaceC0135j, (i4 & 4) != 0 ? null : qVar, (Object) null, (i4 & 16) != 0 ? null : cancellationException);
    }
}
