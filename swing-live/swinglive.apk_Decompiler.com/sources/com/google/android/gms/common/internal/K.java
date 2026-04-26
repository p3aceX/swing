package com.google.android.gms.common.internal;

import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class K extends C {

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final /* synthetic */ AbstractC0283f f3529g;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public K(AbstractC0283f abstractC0283f, int i4) {
        super(abstractC0283f, i4, null);
        this.f3529g = abstractC0283f;
    }

    @Override // com.google.android.gms.common.internal.C
    public final void a(C0771b c0771b) {
        AbstractC0283f abstractC0283f = this.f3529g;
        if (abstractC0283f.enableLocalFallback() && AbstractC0283f.zzo(abstractC0283f)) {
            AbstractC0283f.zzk(abstractC0283f, 16);
        } else {
            abstractC0283f.zzc.a(c0771b);
            abstractC0283f.onConnectionFailed(c0771b);
        }
    }

    @Override // com.google.android.gms.common.internal.C
    public final boolean b() {
        this.f3529g.zzc.a(C0771b.e);
        return true;
    }
}
