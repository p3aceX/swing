package com.google.android.gms.common.internal;

import com.google.android.gms.common.api.internal.InterfaceC0267o;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class t implements InterfaceC0281d, InterfaceC0279b, InterfaceC0280c {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static t f3599b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final u f3600c = new u(0, false, false, 0, 0);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f3601a;

    public /* synthetic */ t(Object obj) {
        this.f3601a = obj;
    }

    public static synchronized t b() {
        try {
            if (f3599b == null) {
                f3599b = new t();
            }
        } catch (Throwable th) {
            throw th;
        }
        return f3599b;
    }

    @Override // com.google.android.gms.common.internal.InterfaceC0281d
    public void a(C0771b c0771b) {
        boolean z4 = c0771b.f6949b == 0;
        AbstractC0283f abstractC0283f = (AbstractC0283f) this.f3601a;
        if (z4) {
            abstractC0283f.getRemoteService(null, abstractC0283f.getScopes());
        } else if (abstractC0283f.zzx != null) {
            ((InterfaceC0267o) ((t) abstractC0283f.zzx).f3601a).a(c0771b);
        }
    }
}
