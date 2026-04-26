package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzux;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzga {
    private static final zzbt<zzbh> zza = zznd.zza("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey", zzbh.class, zzux.zzb.SYMMETRIC, zzvp.zze());
    private static final zznn<zzgj> zzb = new zznn() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfz
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zznn
        public final zzbu zza(zzci zzciVar, Integer num) {
            return zzga.zza((zzgj) zzciVar, null);
        }
    };
    private static final zzoe<zzgk, zzbh> zzc = zzoe.zza(new zzog() { // from class: com.google.android.gms.internal.firebase-auth-api.zzgc
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzog
        public final Object zza(zzbu zzbuVar) {
            return zzga.zzb((zzgk) zzbuVar);
        }
    }, zzgk.class, zzbh.class);

    /* JADX INFO: Access modifiers changed from: private */
    public static zzbh zzb(zzgk zzgkVar) throws GeneralSecurityException {
        try {
            zzvd zzvdVarZza = zzvd.zza(zzcv.zza(zzgkVar.zzb().zzb()), zzaip.zza());
            String strZzc = zzgkVar.zzb().zzc();
            return new zzfx(zzvdVarZza, zzcg.zza(strZzc).zza(strZzc));
        } catch (zzajj e) {
            throw new GeneralSecurityException("Parsing of DEK key template failed: ", e);
        }
    }

    public static /* synthetic */ zzgk zza(zzgj zzgjVar, Integer num) throws GeneralSecurityException {
        if (num == null) {
            return zzgk.zza(zzgjVar);
        }
        throw new GeneralSecurityException("Id Requirement is not supported for LegacyKmsEnvelopeAeadKey");
    }

    public static void zza(boolean z4) {
        zzgo.zza();
        zznk.zza().zza(zzb, zzgj.class);
        zzns.zza().zza(zzc);
        zzcu.zza((zzbt) zza, true);
    }
}
