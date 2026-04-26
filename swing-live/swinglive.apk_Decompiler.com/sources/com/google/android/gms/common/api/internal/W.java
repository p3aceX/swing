package com.google.android.gms.common.api.internal;

import android.os.DeadObjectException;
import android.os.RemoteException;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class W extends K {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final TaskCompletionSource f3442b;

    public W(int i4, TaskCompletionSource taskCompletionSource) {
        super(i4);
        this.f3442b = taskCompletionSource;
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void a(Status status) {
        this.f3442b.trySetException(new com.google.android.gms.common.api.j(status));
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void b(RuntimeException runtimeException) {
        this.f3442b.trySetException(runtimeException);
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void c(E e) throws DeadObjectException {
        try {
            h(e);
        } catch (DeadObjectException e4) {
            a(X.e(e4));
            throw e4;
        } catch (RemoteException e5) {
            a(X.e(e5));
        } catch (RuntimeException e6) {
            this.f3442b.trySetException(e6);
        }
    }

    @Override // com.google.android.gms.common.api.internal.K
    public final boolean f(E e) {
        B1.a.p(e.f3397f.get(null));
        return false;
    }

    @Override // com.google.android.gms.common.api.internal.K
    public final C0773d[] g(E e) {
        B1.a.p(e.f3397f.get(null));
        return null;
    }

    public final void h(E e) {
        B1.a.p(e.f3397f.remove(null));
        this.f3442b.trySetResult(Boolean.FALSE);
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final /* bridge */ /* synthetic */ void d(C0276y c0276y, boolean z4) {
    }
}
