package com.google.android.gms.common.api;

import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class w extends UnsupportedOperationException {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0773d f3503a;

    public w(C0773d c0773d) {
        this.f3503a = c0773d;
    }

    @Override // java.lang.Throwable
    public final String getMessage() {
        return "Missing ".concat(String.valueOf(this.f3503a));
    }
}
