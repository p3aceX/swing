package com.google.android.recaptcha.internal;

import Q3.I;
import Q3.q0;
import com.google.android.gms.tasks.CancellationTokenSource;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
public final class zzj {
    /* JADX WARN: Multi-variable type inference failed */
    public static final Task zza(I i4) {
        TaskCompletionSource taskCompletionSource = new TaskCompletionSource(new CancellationTokenSource().getToken());
        ((q0) i4).q(new zzi(taskCompletionSource, i4));
        return taskCompletionSource.getTask();
    }
}
