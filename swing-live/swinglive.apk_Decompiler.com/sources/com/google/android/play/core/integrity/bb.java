package com.google.android.play.core.integrity;

import android.app.PendingIntent;
import com.google.android.play.core.integrity.StandardIntegrityManager;

/* JADX INFO: loaded from: classes.dex */
final class bb extends StandardIntegrityManager.StandardIntegrityToken {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final String f3686a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final u f3687b;

    public bb(String str, Q0.v vVar, PendingIntent pendingIntent) {
        this.f3686a = str;
        this.f3687b = new u(vVar, pendingIntent);
    }

    @Override // com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityToken
    public final String token() {
        return this.f3686a;
    }
}
