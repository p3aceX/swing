package Q3;

import java.util.concurrent.CancellationException;

/* JADX INFO: renamed from: Q3.i0, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0134i0 extends CancellationException implements InterfaceC0150w {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final transient q0 f1633a;

    public C0134i0(String str, Throwable th, q0 q0Var) {
        super(str);
        this.f1633a = q0Var;
        if (th != null) {
            initCause(th);
        }
    }

    @Override // Q3.InterfaceC0150w
    public final /* bridge */ /* synthetic */ Throwable a() {
        return null;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0134i0)) {
            return false;
        }
        C0134i0 c0134i0 = (C0134i0) obj;
        if (!J3.i.a(c0134i0.getMessage(), getMessage())) {
            return false;
        }
        Object obj2 = c0134i0.f1633a;
        if (obj2 == null) {
            obj2 = t0.f1659b;
        }
        Object obj3 = this.f1633a;
        if (obj3 == null) {
            obj3 = t0.f1659b;
        }
        return J3.i.a(obj2, obj3) && J3.i.a(c0134i0.getCause(), getCause());
    }

    @Override // java.lang.Throwable
    public final Throwable fillInStackTrace() {
        setStackTrace(new StackTraceElement[0]);
        return this;
    }

    public final int hashCode() {
        String message = getMessage();
        J3.i.b(message);
        int iHashCode = message.hashCode() * 31;
        Object obj = this.f1633a;
        if (obj == null) {
            obj = t0.f1659b;
        }
        int iHashCode2 = (iHashCode + (obj != null ? obj.hashCode() : 0)) * 31;
        Throwable cause = getCause();
        return iHashCode2 + (cause != null ? cause.hashCode() : 0);
    }

    @Override // java.lang.Throwable
    public final String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(super.toString());
        sb.append("; job=");
        Object obj = this.f1633a;
        if (obj == null) {
            obj = t0.f1659b;
        }
        sb.append(obj);
        return sb.toString();
    }
}
