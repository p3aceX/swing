package z0;

import O.AbstractActivityC0114z;
import O.C0113y;
import O.DialogInterfaceOnCancelListenerC0106q;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import com.google.android.gms.common.internal.F;

/* JADX INFO: renamed from: z0.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0780k extends DialogInterfaceOnCancelListenerC0106q {

    /* JADX INFO: renamed from: m0, reason: collision with root package name */
    public AlertDialog f6970m0;
    public DialogInterface.OnCancelListener n0;

    /* JADX INFO: renamed from: o0, reason: collision with root package name */
    public AlertDialog f6971o0;

    @Override // O.DialogInterfaceOnCancelListenerC0106q
    public final Dialog I() {
        AlertDialog alertDialog = this.f6970m0;
        if (alertDialog != null) {
            return alertDialog;
        }
        this.f1366d0 = false;
        if (this.f6971o0 == null) {
            C0113y c0113y = this.f1425z;
            AbstractActivityC0114z abstractActivityC0114z = c0113y == null ? null : c0113y.f1433c;
            F.g(abstractActivityC0114z);
            this.f6971o0 = new AlertDialog.Builder(abstractActivityC0114z).create();
        }
        return this.f6971o0;
    }

    @Override // O.DialogInterfaceOnCancelListenerC0106q, android.content.DialogInterface.OnCancelListener
    public final void onCancel(DialogInterface dialogInterface) {
        DialogInterface.OnCancelListener onCancelListener = this.n0;
        if (onCancelListener != null) {
            onCancelListener.onCancel(dialogInterface);
        }
    }
}
