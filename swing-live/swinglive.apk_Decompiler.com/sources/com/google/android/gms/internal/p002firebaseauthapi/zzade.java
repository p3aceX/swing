package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzade implements Runnable {
    private final /* synthetic */ zzadd zza;
    private final /* synthetic */ zzacy zzb;

    public zzade(zzacy zzacyVar, zzadd zzaddVar) {
        this.zza = zzaddVar;
        this.zzb = zzacyVar;
    }

    @Override // java.lang.Runnable
    public final void run() {
        synchronized (this.zzb.zza.zzh) {
            try {
                if (!this.zzb.zza.zzh.isEmpty()) {
                    this.zza.zza(this.zzb.zza.zzh.get(0), new Object[0]);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
