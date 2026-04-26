package com.google.android.gms.common.api.internal;

import com.google.android.gms.internal.base.zaq;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class C implements InterfaceC0254b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3389a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f3390b;

    public /* synthetic */ C(Object obj, int i4) {
        this.f3389a = i4;
        this.f3390b = obj;
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0254b
    public final void a(boolean z4) {
        switch (this.f3389a) {
            case 0:
                zaq zaqVar = ((C0259g) this.f3390b).f3481n;
                zaqVar.sendMessage(zaqVar.obtainMessage(1, Boolean.valueOf(z4)));
                break;
            default:
                C0779j c0779j = (C0779j) this.f3390b;
                if (!z4) {
                    c0779j.getClass();
                    c0779j.getClass();
                } else {
                    c0779j.getClass();
                    k1.h hVar = (k1.h) c0779j.f6969b;
                    hVar.f5532c.removeCallbacks(hVar.f5533d);
                }
                break;
        }
    }
}
