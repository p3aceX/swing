package com.google.android.gms.common.api.internal;

import java.util.Arrays;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0253a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3449a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final com.google.android.gms.common.api.i f3450b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final com.google.android.gms.common.api.e f3451c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f3452d;

    public C0253a(com.google.android.gms.common.api.i iVar, com.google.android.gms.common.api.e eVar, String str) {
        this.f3450b = iVar;
        this.f3451c = eVar;
        this.f3452d = str;
        this.f3449a = Arrays.hashCode(new Object[]{iVar, eVar, str});
    }

    public final boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0253a)) {
            return false;
        }
        C0253a c0253a = (C0253a) obj;
        return com.google.android.gms.common.internal.F.j(this.f3450b, c0253a.f3450b) && com.google.android.gms.common.internal.F.j(this.f3451c, c0253a.f3451c) && com.google.android.gms.common.internal.F.j(this.f3452d, c0253a.f3452d);
    }

    public final int hashCode() {
        return this.f3449a;
    }
}
