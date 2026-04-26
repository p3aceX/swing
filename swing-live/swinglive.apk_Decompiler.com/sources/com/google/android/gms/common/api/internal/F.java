package com.google.android.gms.common.api.internal;

import java.util.Arrays;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class F {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0253a f3405a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0773d f3406b;

    public /* synthetic */ F(C0253a c0253a, C0773d c0773d) {
        this.f3405a = c0253a;
        this.f3406b = c0773d;
    }

    public final boolean equals(Object obj) {
        if (obj != null && (obj instanceof F)) {
            F f4 = (F) obj;
            if (com.google.android.gms.common.internal.F.j(this.f3405a, f4.f3405a) && com.google.android.gms.common.internal.F.j(this.f3406b, f4.f3406b)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f3405a, this.f3406b});
    }

    public final String toString() {
        com.google.android.gms.common.internal.r rVar = new com.google.android.gms.common.internal.r(this);
        rVar.v(this.f3405a, "key");
        rVar.v(this.f3406b, "feature");
        return rVar.toString();
    }
}
