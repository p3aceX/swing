package com.google.android.gms.internal.p002firebaseauthapi;

import j1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzadc implements zzadd {
    private final /* synthetic */ String zza;

    public zzadc(zzacy zzacyVar, String str) {
        this.zza = str;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzadd
    public final void zza(s sVar, Object... objArr) {
        sVar.onCodeAutoRetrievalTimeOut(this.zza);
    }
}
