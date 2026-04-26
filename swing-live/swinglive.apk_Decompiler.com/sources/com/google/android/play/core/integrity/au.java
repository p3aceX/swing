package com.google.android.play.core.integrity;

import android.app.PendingIntent;
import android.os.Build;
import android.os.Bundle;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class au extends at {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private final Q0.v f3673c;

    public au(ax axVar, TaskCompletionSource taskCompletionSource) {
        super(axVar, taskCompletionSource);
        this.f3673c = new Q0.v("OnRequestIntegrityTokenCallback");
    }

    @Override // com.google.android.play.core.integrity.at, Q0.p
    public final void c(Bundle bundle) {
        super.c(bundle);
        this.f3673c.b("onRequestExpressIntegrityToken", new Object[0]);
        int i4 = bundle.getInt("error");
        if (i4 != 0) {
            this.f3671a.trySetException(new StandardIntegrityException(i4, null));
            return;
        }
        PendingIntent pendingIntent = Build.VERSION.SDK_INT >= 33 ? (PendingIntent) bundle.getParcelable("dialog.intent", PendingIntent.class) : (PendingIntent) bundle.getParcelable("dialog.intent");
        TaskCompletionSource taskCompletionSource = this.f3671a;
        b bVar = new b();
        bVar.c(bundle.getString("token"));
        bVar.b(this.f3673c);
        bVar.a(pendingIntent);
        taskCompletionSource.trySetResult(bVar.d());
    }
}
