package O;

import android.app.Dialog;
import android.content.DialogInterface;

/* JADX INFO: renamed from: O.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class DialogInterfaceOnDismissListenerC0104o implements DialogInterface.OnDismissListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ DialogInterfaceOnCancelListenerC0106q f1358a;

    public DialogInterfaceOnDismissListenerC0104o(DialogInterfaceOnCancelListenerC0106q dialogInterfaceOnCancelListenerC0106q) {
        this.f1358a = dialogInterfaceOnCancelListenerC0106q;
    }

    @Override // android.content.DialogInterface.OnDismissListener
    public final void onDismiss(DialogInterface dialogInterface) {
        DialogInterfaceOnCancelListenerC0106q dialogInterfaceOnCancelListenerC0106q = this.f1358a;
        Dialog dialog = dialogInterfaceOnCancelListenerC0106q.h0;
        if (dialog != null) {
            dialogInterfaceOnCancelListenerC0106q.onDismiss(dialog);
        }
    }
}
