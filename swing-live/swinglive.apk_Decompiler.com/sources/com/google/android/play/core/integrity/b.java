package com.google.android.play.core.integrity;

import android.app.PendingIntent;

/* JADX INFO: loaded from: classes.dex */
final class b extends ba {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private String f3683a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private Q0.v f3684b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private PendingIntent f3685c;

    @Override // com.google.android.play.core.integrity.ba
    public final ba a(PendingIntent pendingIntent) {
        this.f3685c = pendingIntent;
        return this;
    }

    @Override // com.google.android.play.core.integrity.ba
    public final ba b(Q0.v vVar) {
        if (vVar == null) {
            throw new NullPointerException("Null logger");
        }
        this.f3684b = vVar;
        return this;
    }

    @Override // com.google.android.play.core.integrity.ba
    public final ba c(String str) {
        if (str == null) {
            throw new NullPointerException("Null token");
        }
        this.f3683a = str;
        return this;
    }

    @Override // com.google.android.play.core.integrity.ba
    public final bb d() {
        Q0.v vVar;
        String str = this.f3683a;
        if (str != null && (vVar = this.f3684b) != null) {
            return new bb(str, vVar, this.f3685c);
        }
        StringBuilder sb = new StringBuilder();
        if (this.f3683a == null) {
            sb.append(" token");
        }
        if (this.f3684b == null) {
            sb.append(" logger");
        }
        throw new IllegalStateException("Missing required properties:".concat(sb.toString()));
    }
}
