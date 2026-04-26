package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes.dex */
public class zzadf {
    zzace zza;
    Executor zzb;

    public final <ResultT> Task<ResultT> zza(final zzadh<ResultT> zzadhVar) {
        final TaskCompletionSource taskCompletionSource = new TaskCompletionSource();
        this.zzb.execute(new Runnable() { // from class: com.google.android.gms.internal.firebase-auth-api.zzadi
            @Override // java.lang.Runnable
            public final void run() {
                zzadhVar.zza(taskCompletionSource, this.zza.zza);
            }
        });
        return taskCompletionSource.getTask();
    }
}
