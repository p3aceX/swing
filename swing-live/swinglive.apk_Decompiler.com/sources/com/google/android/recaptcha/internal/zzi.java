package com.google.android.recaptcha.internal;

import I3.l;
import J3.j;
import Q3.C0149v;
import Q3.I;
import Q3.InterfaceC0124d0;
import Q3.q0;
import com.google.android.gms.tasks.RuntimeExecutionException;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.concurrent.CancellationException;
import w3.i;

/* JADX INFO: loaded from: classes.dex */
final class zzi extends j implements l {
    final /* synthetic */ TaskCompletionSource zza;
    final /* synthetic */ I zzb;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzi(TaskCompletionSource taskCompletionSource, I i4) {
        super(1);
        this.zza = taskCompletionSource;
        this.zzb = i4;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        Throwable th = (Throwable) obj;
        if (th instanceof CancellationException) {
            this.zza.setException((Exception) th);
        } else {
            q0 q0Var = (q0) this.zzb;
            q0Var.getClass();
            Object obj2 = q0.f1656a.get(q0Var);
            if (obj2 instanceof InterfaceC0124d0) {
                throw new IllegalStateException("This job has not completed yet");
            }
            C0149v c0149v = obj2 instanceof C0149v ? (C0149v) obj2 : null;
            Throwable th2 = c0149v != null ? c0149v.f1666a : null;
            if (th2 == null) {
                this.zza.setResult(this.zzb.d());
            } else {
                TaskCompletionSource taskCompletionSource = this.zza;
                Exception runtimeExecutionException = th2 instanceof Exception ? (Exception) th2 : null;
                if (runtimeExecutionException == null) {
                    runtimeExecutionException = new RuntimeExecutionException(th2);
                }
                taskCompletionSource.setException(runtimeExecutionException);
            }
        }
        return i.f6729a;
    }
}
