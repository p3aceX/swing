package com.google.android.gms.internal.auth;

import H0.a;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import w0.C0700b;

/* JADX INFO: loaded from: classes.dex */
final class zzbm extends zzbd {
    final /* synthetic */ TaskCompletionSource zza;

    public zzbm(zzbo zzboVar, TaskCompletionSource taskCompletionSource) {
        this.zza = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.auth.zzbd, com.google.android.gms.internal.auth.zzbg
    public final void zzb(C0700b c0700b) {
        a.d0(new Status(c0700b.f6688a, null), c0700b, this.zza);
    }
}
