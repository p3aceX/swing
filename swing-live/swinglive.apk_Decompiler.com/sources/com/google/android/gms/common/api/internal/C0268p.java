package com.google.android.gms.common.api.internal;

import java.util.concurrent.TimeUnit;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.p, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0268p extends com.google.android.gms.common.api.q {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final BasePendingResult f3485a;

    public C0268p(BasePendingResult basePendingResult) {
        this.f3485a = basePendingResult;
    }

    @Override // com.google.android.gms.common.api.q
    public final com.google.android.gms.common.api.s await(long j4, TimeUnit timeUnit) {
        return this.f3485a.await(0L, TimeUnit.MILLISECONDS);
    }
}
