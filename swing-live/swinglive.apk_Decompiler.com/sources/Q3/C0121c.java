package Q3;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import z0.C0779j;

/* JADX INFO: renamed from: Q3.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0121c extends AbstractC0140l0 {

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f1615n = AtomicReferenceFieldUpdater.newUpdater(C0121c.class, Object.class, "_disposer$volatile");
    private volatile /* synthetic */ Object _disposer$volatile;
    public final C0141m e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Q f1616f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ C0125e f1617m;

    public C0121c(C0125e c0125e, C0141m c0141m) {
        this.f1617m = c0125e;
        this.e = c0141m;
    }

    @Override // Q3.AbstractC0140l0
    public final boolean m() {
        return false;
    }

    @Override // Q3.AbstractC0140l0
    public final void n(Throwable th) throws IllegalAccessException, L, InvocationTargetException {
        C0141m c0141m = this.e;
        if (th != null) {
            c0141m.getClass();
            C0779j c0779jD = c0141m.D(new C0149v(th, false), null);
            if (c0779jD != null) {
                c0141m.o(c0779jD);
                C0123d c0123d = (C0123d) f1615n.get(this);
                if (c0123d != null) {
                    c0123d.b();
                    return;
                }
                return;
            }
            return;
        }
        AtomicIntegerFieldUpdater atomicIntegerFieldUpdater = C0125e.f1620b;
        C0125e c0125e = this.f1617m;
        if (atomicIntegerFieldUpdater.decrementAndGet(c0125e) == 0) {
            I[] iArr = c0125e.f1621a;
            ArrayList arrayList = new ArrayList(iArr.length);
            for (I i4 : iArr) {
                arrayList.add(i4.d());
            }
            c0141m.resumeWith(arrayList);
        }
    }
}
