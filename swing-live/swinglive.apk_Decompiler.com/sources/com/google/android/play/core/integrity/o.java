package com.google.android.play.core.integrity;

import android.content.Context;

/* JADX INFO: loaded from: classes.dex */
final class o {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final o f3707a = this;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private final Q0.h f3708b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private final Q0.h f3709c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    private final Q0.h f3710d;
    private final Q0.h e;

    public o(Context context, n nVar) {
        if (context == null) {
            throw new NullPointerException("instance cannot be null");
        }
        H0.b bVar = new H0.b(context);
        this.f3708b = bVar;
        Q0.f fVarB = Q0.f.b(y.f3722a);
        this.f3709c = fVarB;
        Q0.f fVarB2 = Q0.f.b(new af(bVar, fVarB));
        this.f3710d = fVarB2;
        this.e = Q0.f.b(new x(fVarB2));
    }

    public final IntegrityManager a() {
        return (IntegrityManager) this.e.a();
    }
}
