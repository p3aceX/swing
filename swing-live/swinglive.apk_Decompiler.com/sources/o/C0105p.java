package O;

import a.AbstractC0184a;
import android.app.Dialog;
import android.view.View;

/* JADX INFO: renamed from: O.p, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0105p extends AbstractC0184a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0107s f1359b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ DialogInterfaceOnCancelListenerC0106q f1360c;

    public C0105p(DialogInterfaceOnCancelListenerC0106q dialogInterfaceOnCancelListenerC0106q, C0107s c0107s) {
        this.f1360c = dialogInterfaceOnCancelListenerC0106q;
        this.f1359b = c0107s;
    }

    @Override // a.AbstractC0184a
    public final View Q(int i4) {
        this.f1359b.R();
        Dialog dialog = this.f1360c.h0;
        if (dialog != null) {
            return dialog.findViewById(i4);
        }
        return null;
    }

    @Override // a.AbstractC0184a
    public final boolean R() {
        this.f1359b.R();
        return this.f1360c.f1373l0;
    }
}
