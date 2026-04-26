package io.ktor.utils.io;

import Q3.InterfaceC0150w;
import java.util.concurrent.CancellationException;

/* JADX INFO: loaded from: classes.dex */
public final class D {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Throwable f4956a;

    public D(Throwable th) {
        this.f4956a = th;
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final Throwable a(I3.l lVar) {
        Throwable th = this.f4956a;
        if (th == 0) {
            return null;
        }
        if (th instanceof InterfaceC0150w) {
            return ((InterfaceC0150w) th).a();
        }
        if (!(th instanceof CancellationException)) {
            return (Throwable) lVar.invoke(th);
        }
        CancellationException cancellationException = new CancellationException(((CancellationException) th).getMessage());
        cancellationException.initCause(th);
        return cancellationException;
    }
}
