package Q3;

import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;

/* JADX INFO: loaded from: classes.dex */
public final class S extends AbstractC0140l0 {
    public final /* synthetic */ int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Object f1598f;

    public /* synthetic */ S(Object obj, int i4) {
        this.e = i4;
        this.f1598f = obj;
    }

    @Override // Q3.AbstractC0140l0
    public final boolean m() {
        switch (this.e) {
        }
        return false;
    }

    @Override // Q3.AbstractC0140l0
    public final void n(Throwable th) throws IllegalAccessException, L, InvocationTargetException {
        switch (this.e) {
            case 0:
                ((Q) this.f1598f).a();
                break;
            case 1:
                ((I3.l) this.f1598f).invoke(th);
                break;
            default:
                Object obj = q0.f1656a.get(l());
                boolean z4 = obj instanceof C0149v;
                m0 m0Var = (m0) this.f1598f;
                if (!z4) {
                    m0Var.resumeWith(F.z(obj));
                } else {
                    m0Var.resumeWith(AbstractC0367g.h(((C0149v) obj).f1666a));
                }
                break;
        }
    }
}
