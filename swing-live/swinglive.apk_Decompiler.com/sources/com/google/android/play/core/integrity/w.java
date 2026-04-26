package com.google.android.play.core.integrity;

import com.google.android.gms.tasks.Task;

/* JADX INFO: loaded from: classes.dex */
final class w implements IntegrityManager {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final ad f3720a;

    public w(ad adVar) {
        this.f3720a = adVar;
    }

    @Override // com.google.android.play.core.integrity.IntegrityManager
    public final Task<IntegrityTokenResponse> requestIntegrityToken(IntegrityTokenRequest integrityTokenRequest) {
        return this.f3720a.b(integrityTokenRequest);
    }
}
