package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.common.api.Status;
import j1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzadb implements zzadd {
    private final /* synthetic */ Status zza;

    public zzadb(zzacy zzacyVar, Status status) {
        this.zza = status;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadd
    public final void zza(s sVar, Object... objArr) {
        sVar.onVerificationFailed(zzach.zza(this.zza));
    }
}
