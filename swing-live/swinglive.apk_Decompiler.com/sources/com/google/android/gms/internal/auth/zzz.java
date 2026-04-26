package com.google.android.gms.internal.auth;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import q0.C0629c;

/* JADX INFO: loaded from: classes.dex */
final class zzz extends zzl {
    final /* synthetic */ TaskCompletionSource zza;

    public zzz(zzab zzabVar, TaskCompletionSource taskCompletionSource) {
        this.zza = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.auth.zzm
    public final void zzb(Status status, C0629c c0629c) {
        zzab.zzf(status, c0629c, this.zza);
    }
}
