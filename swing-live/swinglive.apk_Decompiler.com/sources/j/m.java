package j;

import android.widget.PopupWindow;

/* JADX INFO: loaded from: classes.dex */
public final class m implements PopupWindow.OnDismissListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ n f5127a;

    public m(n nVar) {
        this.f5127a = nVar;
    }

    @Override // android.widget.PopupWindow.OnDismissListener
    public final void onDismiss() {
        this.f5127a.c();
    }
}
