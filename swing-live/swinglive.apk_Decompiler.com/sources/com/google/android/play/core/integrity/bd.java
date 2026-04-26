package com.google.android.play.core.integrity;

import com.google.android.gms.tasks.Task;
import com.google.android.play.core.integrity.StandardIntegrityManager;

/* JADX INFO: loaded from: classes.dex */
final class bd {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final ax f3691a;

    public bd(ax axVar) {
        this.f3691a = axVar;
    }

    public final /* synthetic */ Task a(long j4, long j5, StandardIntegrityManager.StandardIntegrityTokenRequest standardIntegrityTokenRequest) {
        return this.f3691a.c(standardIntegrityTokenRequest.a(), j4, j5);
    }
}
