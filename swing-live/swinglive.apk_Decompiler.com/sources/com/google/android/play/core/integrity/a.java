package com.google.android.play.core.integrity;

import android.app.PendingIntent;

/* JADX INFO: loaded from: classes.dex */
final class a extends ag {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private String f3634a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    private Q0.v f3635b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    private PendingIntent f3636c;

    @Override // com.google.android.play.core.integrity.ag
    public final ag a(PendingIntent pendingIntent) {
        this.f3636c = pendingIntent;
        return this;
    }

    @Override // com.google.android.play.core.integrity.ag
    public final ag b(Q0.v vVar) {
        if (vVar == null) {
            throw new NullPointerException("Null logger");
        }
        this.f3635b = vVar;
        return this;
    }

    @Override // com.google.android.play.core.integrity.ag
    public final ag c(String str) {
        this.f3634a = str;
        return this;
    }

    @Override // com.google.android.play.core.integrity.ag
    public final ah d() {
        Q0.v vVar;
        String str = this.f3634a;
        if (str != null && (vVar = this.f3635b) != null) {
            return new ah(str, vVar, this.f3636c);
        }
        StringBuilder sb = new StringBuilder();
        if (this.f3634a == null) {
            sb.append(" token");
        }
        if (this.f3635b == null) {
            sb.append(" logger");
        }
        throw new IllegalStateException("Missing required properties:".concat(sb.toString()));
    }
}
