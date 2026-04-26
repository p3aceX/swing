package com.google.android.play.core.integrity;

import android.app.PendingIntent;
import android.os.Build;
import android.os.Bundle;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class ac extends Q0.t {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    final /* synthetic */ ad f3642a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final Q0.v f3643b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private final TaskCompletionSource f3644c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public ac(ad adVar, TaskCompletionSource taskCompletionSource) {
        super("com.google.android.play.core.integrity.protocol.IIntegrityServiceCallback");
        this.f3642a = adVar;
        this.f3643b = new Q0.v("OnRequestIntegrityTokenCallback");
        this.f3644c = taskCompletionSource;
    }

    @Override // Q0.u
    public final void b(Bundle bundle) {
        this.f3642a.f3645a.c(this.f3644c);
        this.f3643b.b("onRequestIntegrityToken", new Object[0]);
        int i4 = bundle.getInt("error");
        if (i4 != 0) {
            this.f3644c.trySetException(new IntegrityServiceException(i4, null));
            return;
        }
        String string = bundle.getString("token");
        if (string == null) {
            this.f3644c.trySetException(new IntegrityServiceException(-100, null));
            return;
        }
        PendingIntent pendingIntent = Build.VERSION.SDK_INT >= 33 ? (PendingIntent) bundle.getParcelable("dialog.intent", PendingIntent.class) : (PendingIntent) bundle.getParcelable("dialog.intent");
        TaskCompletionSource taskCompletionSource = this.f3644c;
        a aVar = new a();
        aVar.c(string);
        aVar.b(this.f3643b);
        aVar.a(pendingIntent);
        taskCompletionSource.trySetResult(aVar.d());
    }
}
