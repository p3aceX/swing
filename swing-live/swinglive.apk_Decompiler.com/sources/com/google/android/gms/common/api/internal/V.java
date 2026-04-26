package com.google.android.gms.common.api.internal;

import android.os.DeadObjectException;
import android.os.RemoteException;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.Map;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public final class V extends K {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AbstractC0273v f3439b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final TaskCompletionSource f3440c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final InterfaceC0271t f3441d;

    public V(int i4, AbstractC0273v abstractC0273v, TaskCompletionSource taskCompletionSource, InterfaceC0271t interfaceC0271t) {
        super(i4);
        this.f3440c = taskCompletionSource;
        this.f3439b = abstractC0273v;
        this.f3441d = interfaceC0271t;
        if (i4 == 2 && abstractC0273v.f3488b) {
            throw new IllegalArgumentException("Best-effort write calls cannot pass methods that should auto-resolve missing features.");
        }
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void a(Status status) {
        ((X.N) this.f3441d).getClass();
        this.f3440c.trySetException(com.google.android.gms.common.internal.F.k(status));
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void b(RuntimeException runtimeException) {
        this.f3440c.trySetException(runtimeException);
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void c(E e) throws DeadObjectException {
        TaskCompletionSource taskCompletionSource = this.f3440c;
        try {
            AbstractC0273v abstractC0273v = this.f3439b;
            ((InterfaceC0270s) ((P) abstractC0273v).f3433d.f159c).accept(e.f3394b, taskCompletionSource);
        } catch (DeadObjectException e4) {
            throw e4;
        } catch (RemoteException e5) {
            a(X.e(e5));
        } catch (RuntimeException e6) {
            taskCompletionSource.trySetException(e6);
        }
    }

    @Override // com.google.android.gms.common.api.internal.X
    public final void d(C0276y c0276y, boolean z4) {
        Boolean boolValueOf = Boolean.valueOf(z4);
        Map map = (Map) c0276y.f3493b;
        TaskCompletionSource taskCompletionSource = this.f3440c;
        map.put(taskCompletionSource, boolValueOf);
        taskCompletionSource.getTask().addOnCompleteListener(new C0276y(c0276y, taskCompletionSource));
    }

    @Override // com.google.android.gms.common.api.internal.K
    public final boolean f(E e) {
        return this.f3439b.f3488b;
    }

    @Override // com.google.android.gms.common.api.internal.K
    public final C0773d[] g(E e) {
        return this.f3439b.f3487a;
    }
}
