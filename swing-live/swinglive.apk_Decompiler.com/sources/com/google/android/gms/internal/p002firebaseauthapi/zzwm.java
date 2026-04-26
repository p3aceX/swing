package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzjl;
import java.security.GeneralSecurityException;
import java.security.interfaces.ECPublicKey;

/* JADX INFO: loaded from: classes.dex */
public final class zzwm implements zzbs {
    private static final byte[] zza = new byte[0];
    private static final zzmf<zzwq, zzjl.zzc> zzb = zzmf.zza().zza(zzwq.NIST_P256, zzjl.zzc.zza).zza(zzwq.NIST_P384, zzjl.zzc.zzb).zza(zzwq.NIST_P521, zzjl.zzc.zzc).zza();
    private static final zzmf<zzwp, zzjl.zze> zzc = zzmf.zza().zza(zzwp.UNCOMPRESSED, zzjl.zze.zzb).zza(zzwp.COMPRESSED, zzjl.zze.zza).zza(zzwp.DO_NOT_USE_CRUNCHY_UNCOMPRESSED, zzjl.zze.zzc).zza();
    private final zzwo zzd;
    private final String zze;
    private final byte[] zzf;
    private final zzwp zzg;
    private final zzwk zzh;
    private final byte[] zzi;

    public zzwm(ECPublicKey eCPublicKey, byte[] bArr, String str, zzwp zzwpVar, zzwk zzwkVar) {
        this(eCPublicKey, bArr, str, zzwpVar, zzwkVar, new byte[0]);
    }

    private zzwm(ECPublicKey eCPublicKey, byte[] bArr, String str, zzwp zzwpVar, zzwk zzwkVar, byte[] bArr2) throws GeneralSecurityException {
        zzmd.zza(eCPublicKey.getW(), eCPublicKey.getParams().getCurve());
        this.zzd = new zzwo(eCPublicKey);
        this.zzf = bArr;
        this.zze = str;
        this.zzg = zzwpVar;
        this.zzh = zzwkVar;
        this.zzi = bArr2;
    }
}
