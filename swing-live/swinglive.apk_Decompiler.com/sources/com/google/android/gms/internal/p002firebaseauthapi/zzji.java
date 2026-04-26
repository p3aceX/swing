package com.google.android.gms.internal.p002firebaseauthapi;

import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;
import java.security.spec.ECPublicKeySpec;

/* JADX INFO: loaded from: classes.dex */
final class zzji extends zzoi<zzbs, zztt> {
    public zzji(Class cls) {
        super(cls);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoi
    public final /* synthetic */ zzbs zza(zzakk zzakkVar) throws GeneralSecurityException {
        zztt zzttVar = (zztt) zzakkVar;
        zztp zztpVarZzb = zzttVar.zzb();
        zztw zztwVarZzf = zztpVarZzb.zzf();
        zzwq zzwqVarZza = zzku.zza(zztwVarZzf.zzd());
        byte[] bArrZzg = zzttVar.zzf().zzg();
        byte[] bArrZzg2 = zzttVar.zzg().zzg();
        ECParameterSpec eCParameterSpecZza = zzwn.zza(zzwqVarZza);
        ECPoint eCPoint = new ECPoint(new BigInteger(1, bArrZzg), new BigInteger(1, bArrZzg2));
        zzmd.zza(eCPoint, eCParameterSpecZza.getCurve());
        return new zzwm((ECPublicKey) zzwr.zze.zza("EC").generatePublic(new ECPublicKeySpec(eCPoint, eCParameterSpecZza)), zztwVarZzf.zzf().zzg(), zzku.zza(zztwVarZzf.zze()), zzku.zza(zztpVarZzb.zza()), new zzkw(zztpVarZzb.zzb().zzd()));
    }
}
