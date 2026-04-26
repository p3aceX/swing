package V3;

import y3.InterfaceC0767h;

/* JADX INFO: loaded from: classes.dex */
public final class f extends RuntimeException {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final transient InterfaceC0767h f2222a;

    public f(InterfaceC0767h interfaceC0767h) {
        this.f2222a = interfaceC0767h;
    }

    @Override // java.lang.Throwable
    public final Throwable fillInStackTrace() {
        setStackTrace(new StackTraceElement[0]);
        return this;
    }

    @Override // java.lang.Throwable
    public final String getLocalizedMessage() {
        return String.valueOf(this.f2222a);
    }
}
