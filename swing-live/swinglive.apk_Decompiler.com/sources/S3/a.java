package S3;

import Q3.F;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.CancellationException;

/* JADX INFO: loaded from: classes.dex */
public class a extends j implements b {
    @Override // Q3.q0
    public final boolean J(Throwable th) throws IllegalAccessException, InvocationTargetException {
        F.o(th, this.f1612c);
        return true;
    }

    @Override // Q3.q0
    public final void T(Throwable th) {
        if (th != null) {
            cancellationException = th instanceof CancellationException ? (CancellationException) th : null;
            if (cancellationException == null) {
                CancellationException cancellationException = new CancellationException(getClass().getSimpleName().concat(" was cancelled"));
                cancellationException.initCause(th);
                cancellationException = cancellationException;
            }
        }
        this.f1851d.a(cancellationException);
    }
}
