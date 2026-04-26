package com.google.android.gms.common.internal;

import android.os.Bundle;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public abstract class C {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Boolean f3513a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f3514b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ AbstractC0283f f3515c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f3516d;
    public final Bundle e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final /* synthetic */ AbstractC0283f f3517f;

    public C(AbstractC0283f abstractC0283f, int i4, Bundle bundle) {
        this.f3517f = abstractC0283f;
        Boolean bool = Boolean.TRUE;
        this.f3515c = abstractC0283f;
        this.f3513a = bool;
        this.f3514b = false;
        this.f3516d = i4;
        this.e = bundle;
    }

    public abstract void a(C0771b c0771b);

    public abstract boolean b();

    public final void c() {
        synchronized (this) {
            this.f3513a = null;
        }
        synchronized (this.f3515c.zzt) {
            this.f3515c.zzt.remove(this);
        }
    }
}
