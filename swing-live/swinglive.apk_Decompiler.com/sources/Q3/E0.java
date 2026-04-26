package Q3;

import java.util.concurrent.CancellationException;

/* JADX INFO: loaded from: classes.dex */
public final class E0 extends CancellationException implements InterfaceC0150w {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final transient F0 f1575a;

    public E0(String str, F0 f02) {
        super(str);
        this.f1575a = f02;
    }

    @Override // Q3.InterfaceC0150w
    public final Throwable a() {
        String message = getMessage();
        if (message == null) {
            message = "";
        }
        E0 e02 = new E0(message, this.f1575a);
        e02.initCause(this);
        return e02;
    }
}
