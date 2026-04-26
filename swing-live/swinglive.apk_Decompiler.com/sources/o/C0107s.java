package O;

import a.AbstractC0184a;
import android.view.View;

/* JADX INFO: renamed from: O.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0107s extends AbstractC0184a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ AbstractComponentCallbacksC0109u f1375b;

    public C0107s(AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u) {
        this.f1375b = abstractComponentCallbacksC0109u;
    }

    @Override // a.AbstractC0184a
    public final View Q(int i4) {
        AbstractComponentCallbacksC0109u abstractComponentCallbacksC0109u = this.f1375b;
        abstractComponentCallbacksC0109u.getClass();
        throw new IllegalStateException("Fragment " + abstractComponentCallbacksC0109u + " does not have a view");
    }

    @Override // a.AbstractC0184a
    public final boolean R() {
        this.f1375b.getClass();
        return false;
    }
}
