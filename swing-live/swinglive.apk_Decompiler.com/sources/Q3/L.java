package Q3;

import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class L extends Exception {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Throwable f1593a;

    public L(Throwable th, A a5, InterfaceC0767h interfaceC0767h) {
        super("Coroutine dispatcher " + a5 + " threw an exception, context = " + interfaceC0767h, th);
        this.f1593a = th;
    }

    @Override // java.lang.Throwable
    public final Throwable getCause() {
        return this.f1593a;
    }
}
