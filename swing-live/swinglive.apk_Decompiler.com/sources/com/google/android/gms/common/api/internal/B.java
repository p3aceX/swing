package com.google.android.gms.common.api.internal;

import android.os.Handler;
import com.google.android.gms.internal.base.zaq;
import java.util.concurrent.Executor;
import java.util.concurrent.RejectedExecutionException;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class B implements Executor {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f3387a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Handler f3388b;

    public /* synthetic */ B(Handler handler, int i4) {
        this.f3387a = i4;
        this.f3388b = handler;
    }

    @Override // java.util.concurrent.Executor
    public final void execute(Runnable runnable) {
        switch (this.f3387a) {
            case 0:
                ((zaq) this.f3388b).post(runnable);
                return;
            default:
                runnable.getClass();
                Handler handler = this.f3388b;
                if (handler.post(runnable)) {
                    return;
                }
                throw new RejectedExecutionException(handler + " is shutting down");
        }
    }
}
