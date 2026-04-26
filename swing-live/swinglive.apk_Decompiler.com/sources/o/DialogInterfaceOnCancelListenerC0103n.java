package O;

import android.app.Dialog;
import android.content.DialogInterface;

/* JADX INFO: renamed from: O.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class DialogInterfaceOnCancelListenerC0103n implements DialogInterface.OnCancelListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ DialogInterfaceOnCancelListenerC0106q f1357a;

    public DialogInterfaceOnCancelListenerC0103n(DialogInterfaceOnCancelListenerC0106q dialogInterfaceOnCancelListenerC0106q) {
        this.f1357a = dialogInterfaceOnCancelListenerC0106q;
    }

    @Override // android.content.DialogInterface.OnCancelListener
    public final void onCancel(DialogInterface dialogInterface) {
        DialogInterfaceOnCancelListenerC0106q dialogInterfaceOnCancelListenerC0106q = this.f1357a;
        Dialog dialog = dialogInterfaceOnCancelListenerC0106q.h0;
        if (dialog != null) {
            dialogInterfaceOnCancelListenerC0106q.onCancel(dialog);
        }
    }
}
