package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzje extends zzoq<zzts, zztt> {
    public zzje() {
        super(zzts.class, zztt.class, new zzjh(zzbp.class));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzic.zza zza() {
        return zzic.zza.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzna<zzto, zzts> zzb() {
        return new zzjg(this, zzto.class);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final zzux.zzb zzc() {
        return zzux.zzb.ASYMMETRIC_PRIVATE;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final String zzd() {
        return "type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey";
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoq
    public final /* synthetic */ zzakk zza(zzakk zzakkVar) {
        return ((zzts) zzakkVar).zzd();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final /* synthetic */ void zzb(zzakk zzakkVar) throws GeneralSecurityException {
        zzts zztsVar = (zzts) zzakkVar;
        if (zztsVar.zze().zze()) {
            throw new GeneralSecurityException("invalid ECIES private key");
        }
        zzxq.zza(zztsVar.zza(), 0);
        zzku.zza(zztsVar.zzd().zzb());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznb
    public final /* synthetic */ zzakk zza(zzahm zzahmVar) {
        return zzts.zza(zzahmVar, zzaip.zza());
    }
}
