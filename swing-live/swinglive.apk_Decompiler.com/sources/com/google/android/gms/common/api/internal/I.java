package com.google.android.gms.common.api.internal;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import com.google.android.gms.internal.base.zaq;

/* JADX INFO: loaded from: classes.dex */
public final class I extends BroadcastReceiver {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Context f3413a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0276y f3414b;

    public I(C0276y c0276y) {
        this.f3414b = c0276y;
    }

    @Override // android.content.BroadcastReceiver
    public final void onReceive(Context context, Intent intent) {
        Uri data = intent.getData();
        if ("com.google.android.gms".equals(data != null ? data.getSchemeSpecificPart() : null)) {
            C0276y c0276y = this.f3414b;
            DialogInterfaceOnCancelListenerC0277z dialogInterfaceOnCancelListenerC0277z = (DialogInterfaceOnCancelListenerC0277z) ((Z) c0276y.f3493b).f3448c;
            dialogInterfaceOnCancelListenerC0277z.f3495b.set(null);
            zaq zaqVar = dialogInterfaceOnCancelListenerC0277z.f3498f.f3481n;
            zaqVar.sendMessage(zaqVar.obtainMessage(3));
            AlertDialog alertDialog = (AlertDialog) c0276y.f3492a;
            if (alertDialog.isShowing()) {
                alertDialog.dismiss();
            }
            synchronized (this) {
                try {
                    Context context2 = this.f3413a;
                    if (context2 != null) {
                        context2.unregisterReceiver(this);
                    }
                    this.f3413a = null;
                } catch (Throwable th) {
                    throw th;
                }
            }
        }
    }
}
