package com.google.android.gms.common.api.internal;

/* JADX INFO: loaded from: classes.dex */
public final class D implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3391a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ E f3392b;

    public D(E e, int i4) {
        this.f3392b = e;
        this.f3391a = i4;
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.f3392b.i(this.f3391a);
    }
}
