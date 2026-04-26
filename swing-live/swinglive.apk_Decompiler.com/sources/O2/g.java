package O2;

import java.io.IOException;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicBoolean f1449a = new AtomicBoolean(false);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0747k f1450b;

    public g(C0747k c0747k) {
        this.f1450b = c0747k;
    }

    public final void a(Object obj) throws IOException {
        if (this.f1449a.get()) {
            return;
        }
        C0747k c0747k = this.f1450b;
        if (((AtomicReference) c0747k.f6832c).get() != this) {
            return;
        }
        C0747k c0747k2 = (C0747k) c0747k.f6833d;
        ((f) c0747k2.f6831b).i((String) c0747k2.f6832c, ((r) c0747k2.f6833d).b(obj));
    }
}
