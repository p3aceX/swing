package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzlk extends zzoq<zzut, zzuw> {
    public zzlk() {
        super(zzut.class, zzuw.class, new zzlj(zzbp.class));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzic.zza zza() {
        return zzic.zza.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzna<zzuo, zzut> zzb() {
        return new zzlm(this, zzuo.class);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzux.zzb zzc() {
        return zzux.zzb.ASYMMETRIC_PRIVATE;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final String zzd() {
        return "type.googleapis.com/google.crypto.tink.HpkePrivateKey";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoq
    public final /* synthetic */ zzakk zza(zzakk zzakkVar) {
        return ((zzut) zzakkVar).zzd();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final /* synthetic */ void zzb(zzakk zzakkVar) throws GeneralSecurityException {
        zzut zzutVar = (zzut) zzakkVar;
        if (zzutVar.zze().zze()) {
            throw new GeneralSecurityException("Private key is empty.");
        }
        if (!zzutVar.zzf()) {
            throw new GeneralSecurityException("Missing public key.");
        }
        zzxq.zza(zzutVar.zza(), 0);
        zzlq.zza(zzutVar.zzd().zzb());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final /* synthetic */ zzakk zza(zzahm zzahmVar) {
        return zzut.zza(zzahmVar, zzaip.zza());
    }
}
