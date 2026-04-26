package com.google.android.gms.internal.p002firebaseauthapi;

import g1.h;
import j1.q;
import j1.r;
import j1.s;

/* JADX INFO: loaded from: classes.dex */
final class zzadr extends s {
    private final /* synthetic */ s zza;
    private final /* synthetic */ String zzb;

    public zzadr(s sVar, String str) {
        this.zza = sVar;
        this.zzb = str;
    }

    @Override // j1.s
    public final void onCodeAutoRetrievalTimeOut(String str) {
        zzads.zza.remove(this.zzb);
        this.zza.onCodeAutoRetrievalTimeOut(str);
    }

    @Override // j1.s
    public final void onCodeSent(String str, r rVar) {
        this.zza.onCodeSent(str, rVar);
    }

    @Override // j1.s
    public final void onVerificationCompleted(q qVar) {
        zzads.zza.remove(this.zzb);
        this.zza.onVerificationCompleted(qVar);
    }

    @Override // j1.s
    public final void onVerificationFailed(h hVar) {
        zzads.zza.remove(this.zzb);
        this.zza.onVerificationFailed(hVar);
    }
}
