package com.google.android.gms.common.api.internal;

import z0.C0773d;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0273v {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0773d[] f3487a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f3488b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f3489c;

    public AbstractC0273v(C0773d[] c0773dArr, boolean z4, int i4) {
        this.f3487a = c0773dArr;
        boolean z5 = false;
        if (c0773dArr != null && z4) {
            z5 = true;
        }
        this.f3488b = z5;
        this.f3489c = i4;
    }

    public static D2.C a() {
        D2.C c5 = new D2.C();
        c5.f157a = true;
        c5.f158b = 0;
        return c5;
    }
}
