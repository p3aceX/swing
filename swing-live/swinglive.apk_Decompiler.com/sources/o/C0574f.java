package o;

import e1.k;

/* JADX INFO: renamed from: o.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0574f extends k {
    @Override // e1.k
    public final void B(C0575g c0575g, C0575g c0575g2) {
        c0575g.f5950b = c0575g2;
    }

    @Override // e1.k
    public final void C(C0575g c0575g, Thread thread) {
        c0575g.f5949a = thread;
    }

    @Override // e1.k
    public final boolean d(AbstractFutureC0576h abstractFutureC0576h, C0572d c0572d) {
        C0572d c0572d2 = C0572d.f5942b;
        synchronized (abstractFutureC0576h) {
            try {
                if (abstractFutureC0576h.f5955b != c0572d) {
                    return false;
                }
                abstractFutureC0576h.f5955b = c0572d2;
                return true;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    @Override // e1.k
    public final boolean e(AbstractFutureC0576h abstractFutureC0576h, Object obj, Object obj2) {
        synchronized (abstractFutureC0576h) {
            try {
                if (abstractFutureC0576h.f5954a != obj) {
                    return false;
                }
                abstractFutureC0576h.f5954a = obj2;
                return true;
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    @Override // e1.k
    public final boolean f(AbstractFutureC0576h abstractFutureC0576h, C0575g c0575g, C0575g c0575g2) {
        synchronized (abstractFutureC0576h) {
            try {
                if (abstractFutureC0576h.f5956c != c0575g) {
                    return false;
                }
                abstractFutureC0576h.f5956c = c0575g2;
                return true;
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
