package z0;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.os.Bundle;
import com.google.android.gms.common.internal.F;

/* JADX INFO: renamed from: z0.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class DialogFragmentC0772c extends DialogFragment {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public AlertDialog f6952a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public DialogInterface.OnCancelListener f6953b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public AlertDialog f6954c;

    @Override // android.app.DialogFragment, android.content.DialogInterface.OnCancelListener
    public final void onCancel(DialogInterface dialogInterface) {
        DialogInterface.OnCancelListener onCancelListener = this.f6953b;
        if (onCancelListener != null) {
            onCancelListener.onCancel(dialogInterface);
        }
    }

    @Override // android.app.DialogFragment
    public final Dialog onCreateDialog(Bundle bundle) {
        AlertDialog alertDialog = this.f6952a;
        if (alertDialog != null) {
            return alertDialog;
        }
        setShowsDialog(false);
        if (this.f6954c == null) {
            Activity activity = getActivity();
            F.g(activity);
            this.f6954c = new AlertDialog.Builder(activity).create();
        }
        return this.f6954c;
    }
}
