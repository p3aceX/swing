package com.google.android.play.core.integrity;

import android.os.Bundle;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
final class av extends at {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private final Q0.v f3674c;

    public av(ax axVar, TaskCompletionSource taskCompletionSource) {
        super(axVar, taskCompletionSource);
        this.f3674c = new Q0.v("OnWarmUpIntegrityTokenCallback");
    }

    @Override // com.google.android.play.core.integrity.at, Q0.p
    public final void e(Bundle bundle) {
        super.e(bundle);
        this.f3674c.b("onWarmUpExpressIntegrityToken", new Object[0]);
        int i4 = bundle.getInt("error");
        if (i4 != 0) {
            this.f3671a.trySetException(new StandardIntegrityException(i4, null));
        } else {
            this.f3671a.trySetResult(Long.valueOf(bundle.getLong("warm.up.sid")));
        }
    }
}
