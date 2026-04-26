package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.firebase.auth.FirebaseAuth;
import j1.AbstractC0458c;

/* JADX INFO: loaded from: classes.dex */
public final class zzadg<ResultT, CallbackT> implements zzacx<ResultT> {
    private final zzacw<ResultT, CallbackT> zza;
    private final TaskCompletionSource<ResultT> zzb;

    public zzadg(zzacw<ResultT, CallbackT> zzacwVar, TaskCompletionSource<ResultT> taskCompletionSource) {
        this.zza = zzacwVar;
        this.zzb = taskCompletionSource;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzacx
    public final void zza(ResultT resultt, Status status) {
        F.h(this.zzb, "completion source cannot be null");
        if (status == null) {
            this.zzb.setResult(resultt);
            return;
        }
        zzacw<ResultT, CallbackT> zzacwVar = this.zza;
        if (zzacwVar.zzs != null) {
            TaskCompletionSource<ResultT> taskCompletionSource = this.zzb;
            FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(zzacwVar.zzc);
            zzacw<ResultT, CallbackT> zzacwVar2 = this.zza;
            taskCompletionSource.setException(zzach.zza(firebaseAuth, zzacwVar2.zzs, ("reauthenticateWithCredential".equals(zzacwVar2.zza()) || "reauthenticateWithCredentialWithData".equals(this.zza.zza())) ? this.zza.zzd : null));
            return;
        }
        AbstractC0458c abstractC0458c = zzacwVar.zzp;
        if (abstractC0458c != null) {
            this.zzb.setException(zzach.zza(status, abstractC0458c, zzacwVar.zzq, zzacwVar.zzr));
        } else {
            this.zzb.setException(zzach.zza(status));
        }
    }
}
