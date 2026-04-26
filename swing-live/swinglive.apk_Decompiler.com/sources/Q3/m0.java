package Q3;

import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class m0 extends C0141m {

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final C0146s f1642o;

    public m0(InterfaceC0762c interfaceC0762c, C0146s c0146s) {
        super(1, interfaceC0762c);
        this.f1642o = c0146s;
    }

    @Override // Q3.C0141m
    public final Throwable p(q0 q0Var) {
        Throwable thC;
        C0146s c0146s = this.f1642o;
        c0146s.getClass();
        Object obj = q0.f1656a.get(c0146s);
        return (!(obj instanceof o0) || (thC = ((o0) obj).c()) == null) ? obj instanceof C0149v ? ((C0149v) obj).f1666a : q0Var.f() : thC;
    }

    @Override // Q3.C0141m
    public final String x() {
        return "AwaitContinuation";
    }
}
