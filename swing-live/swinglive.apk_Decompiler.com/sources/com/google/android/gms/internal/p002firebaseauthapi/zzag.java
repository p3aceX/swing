package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: loaded from: classes.dex */
final class zzag extends zzaf {
    private final /* synthetic */ zzp zzb;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzag(zzad zzadVar, zzac zzacVar, CharSequence charSequence, zzp zzpVar) {
        super(zzacVar, charSequence);
        this.zzb = zzpVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaf
    public final int zza(int i4) {
        return this.zzb.zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaf
    public final int zzb(int i4) {
        if (this.zzb.zza(i4)) {
            return this.zzb.zzb();
        }
        return -1;
    }
}
