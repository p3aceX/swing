package com.google.android.play.core.integrity;

import android.app.PendingIntent;

/* JADX INFO: loaded from: classes.dex */
final class ah extends IntegrityTokenResponse {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final String f3651a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final u f3652b;

    public ah(String str, Q0.v vVar, PendingIntent pendingIntent) {
        this.f3651a = str;
        this.f3652b = new u(vVar, pendingIntent);
    }

    @Override // com.google.android.play.core.integrity.IntegrityTokenResponse
    public final String token() {
        return this.f3651a;
    }
}
