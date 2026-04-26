package com.google.android.play.core.integrity;

import android.content.Context;

/* JADX INFO: loaded from: classes.dex */
final class s {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final s f3712a = this;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final Q0.h f3713b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private final Q0.h f3714c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    private final Q0.h f3715d;
    private final Q0.h e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    private final Q0.h f3716f;

    public s(Context context, r rVar) {
        if (context == null) {
            throw new NullPointerException("instance cannot be null");
        }
        H0.b bVar = new H0.b(context);
        this.f3713b = bVar;
        Q0.f fVarB = Q0.f.b(an.f3660a);
        this.f3714c = fVarB;
        Q0.f fVarB2 = Q0.f.b(new az(bVar, fVarB));
        this.f3715d = fVarB2;
        Q0.f fVarB3 = Q0.f.b(new be(fVarB2));
        this.e = fVarB3;
        this.f3716f = Q0.f.b(new am(fVarB2, fVarB3));
    }

    public final StandardIntegrityManager a() {
        return (StandardIntegrityManager) this.f3716f.a();
    }
}
