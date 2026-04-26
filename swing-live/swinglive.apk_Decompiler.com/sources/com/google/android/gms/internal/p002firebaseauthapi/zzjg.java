package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.interfaces.ECPrivateKey;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;

/* JADX INFO: loaded from: classes.dex */
final class zzjg extends zzna<zzto, zzts> {
    private final /* synthetic */ zzje zza;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzjg(zzje zzjeVar, Class cls) {
        super(cls);
        this.zza = zzjeVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzna
    public final /* synthetic */ zzakk zza(zzakk zzakkVar) throws NoSuchAlgorithmException, InvalidAlgorithmParameterException {
        zzto zztoVar = (zzto) zzakkVar;
        ECParameterSpec eCParameterSpecZza = zzwn.zza(zzku.zza(zztoVar.zzc().zzf().zzd()));
        KeyPairGenerator keyPairGeneratorZza = zzwr.zzd.zza("EC");
        keyPairGeneratorZza.initialize(eCParameterSpecZza);
        KeyPair keyPairGenerateKeyPair = keyPairGeneratorZza.generateKeyPair();
        ECPublicKey eCPublicKey = (ECPublicKey) keyPairGenerateKeyPair.getPublic();
        ECPrivateKey eCPrivateKey = (ECPrivateKey) keyPairGenerateKeyPair.getPrivate();
        ECPoint w4 = eCPublicKey.getW();
        return (zzts) ((zzaja) zzts.zzb().zza(0).zza((zztt) ((zzaja) zztt.zzc().zza(0).zza(zztoVar.zzc()).zza(zzahm.zza(w4.getAffineX().toByteArray())).zzb(zzahm.zza(w4.getAffineY().toByteArray())).zzf())).zza(zzahm.zza(eCPrivateKey.getS().toByteArray())).zzf());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzna
    public final /* synthetic */ void zzb(zzakk zzakkVar) throws GeneralSecurityException {
        zzku.zza(((zzto) zzakkVar).zzc());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzna
    public final /* synthetic */ zzakk zza(zzahm zzahmVar) {
        return zzto.zza(zzahmVar, zzaip.zza());
    }
}
