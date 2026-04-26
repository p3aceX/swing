package com.google.android.gms.internal.p002firebaseauthapi;

import j1.q;
import j1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzacz implements zzadd {
    private final /* synthetic */ q zza;

    public zzacz(zzacy zzacyVar, q qVar) {
        this.zza = qVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadd
    public final void zza(s sVar, Object... objArr) {
        sVar.onVerificationCompleted(this.zza);
    }
}
