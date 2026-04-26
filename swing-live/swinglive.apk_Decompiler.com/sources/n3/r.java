package n3;

import Q3.InterfaceC0137k;
import e1.AbstractC0367g;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public abstract class r implements q {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f5933c = AtomicIntegerFieldUpdater.newUpdater(r.class, "_interestedOps");

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicBoolean f5934a = new AtomicBoolean(false);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final l f5935b = new l();
    private volatile /* synthetic */ int _interestedOps = 0;

    @Override // Q3.Q
    public void a() {
        close();
    }

    public final int b() {
        return this._interestedOps;
    }

    @Override // java.io.Closeable, java.lang.AutoCloseable
    public void close() {
        if (this.f5934a.compareAndSet(false, true)) {
            this._interestedOps = 0;
            l lVar = this.f5935b;
            p.f5925b.getClass();
            for (p pVar : p.f5926c) {
                lVar.getClass();
                J3.i.e(pVar, "interest");
                InterfaceC0137k interfaceC0137k = (InterfaceC0137k) l.f5917a[pVar.ordinal()].getAndSet(lVar, null);
                if (interfaceC0137k != null) {
                    interfaceC0137k.resumeWith(AbstractC0367g.h(new f("Closed channel.")));
                }
            }
        }
    }

    public final void d(p pVar, boolean z4) {
        int i4;
        int i5 = pVar.f5932a;
        do {
            i4 = this._interestedOps;
        } while (!f5933c.compareAndSet(this, i4, z4 ? i4 | i5 : (~i5) & i4));
    }
}
