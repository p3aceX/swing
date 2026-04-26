package com.google.android.gms.tasks;

import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
final class zzk implements Runnable {
    final /* synthetic */ Task zza;
    final /* synthetic */ zzl zzb;

    public zzk(zzl zzlVar, Task task) {
        this.zzb = zzlVar;
        this.zza = task;
    }

    @Override // java.lang.Runnable
    public final void run() {
        synchronized (this.zzb.zzb) {
            try {
                zzl zzlVar = this.zzb;
                if (zzlVar.zzc != null) {
                    OnFailureListener onFailureListener = zzlVar.zzc;
                    Exception exception = this.zza.getException();
                    F.g(exception);
                    onFailureListener.onFailure(exception);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
