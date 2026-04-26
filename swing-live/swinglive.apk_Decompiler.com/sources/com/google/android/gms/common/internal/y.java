package com.google.android.gms.common.internal;

import android.content.ActivityNotFoundException;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import com.google.android.gms.common.api.GoogleApiActivity;
import com.google.android.gms.common.api.internal.InterfaceC0263k;

/* JADX INFO: loaded from: classes.dex */
public final class y implements DialogInterface.OnClickListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3611a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Intent f3612b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Object f3613c;

    public /* synthetic */ y(Intent intent, Object obj, int i4) {
        this.f3611a = i4;
        this.f3612b = intent;
        this.f3613c = obj;
    }

    public final void a() {
        switch (this.f3611a) {
            case 0:
                Intent intent = this.f3612b;
                if (intent != null) {
                    ((GoogleApiActivity) this.f3613c).startActivityForResult(intent, 2);
                }
                break;
            default:
                Intent intent2 = this.f3612b;
                if (intent2 != null) {
                    ((InterfaceC0263k) this.f3613c).f(2, intent2);
                }
                break;
        }
    }

    @Override // android.content.DialogInterface.OnClickListener
    public final void onClick(DialogInterface dialogInterface, int i4) {
        try {
            a();
        } catch (ActivityNotFoundException e) {
            Log.e("DialogRedirect", true == Build.FINGERPRINT.contains("generic") ? "Failed to start resolution intent. This may occur when resolving Google Play services connection issues on emulators with Google APIs but not Google Play Store." : "Failed to start resolution intent.", e);
        } finally {
            dialogInterface.dismiss();
        }
    }
}
