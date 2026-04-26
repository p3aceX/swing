package com.google.android.gms.common.api.internal;

import com.google.android.gms.common.api.Status;
import java.util.Map;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.x, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0275x implements com.google.android.gms.common.api.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ BasePendingResult f3490a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0276y f3491b;

    public C0275x(C0276y c0276y, BasePendingResult basePendingResult) {
        this.f3491b = c0276y;
        this.f3490a = basePendingResult;
    }

    @Override // com.google.android.gms.common.api.p
    public final void a(Status status) {
        ((Map) this.f3491b.f3492a).remove(this.f3490a);
    }
}
