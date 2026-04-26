package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
final class zzls implements zzlg {
    private final zzwq zza;
    private final zzkx zzb;

    private zzls(zzkx zzkxVar, zzwq zzwqVar) {
        this.zzb = zzkxVar;
        this.zza = zzwqVar;
    }

    public static zzls zza(zzwq zzwqVar) throws GeneralSecurityException {
        int i4 = zzlr.zza[zzwqVar.ordinal()];
        if (i4 == 1) {
            return new zzls(new zzkx("HmacSha256"), zzwq.NIST_P256);
        }
        if (i4 == 2) {
            return new zzls(new zzkx("HmacSha384"), zzwq.NIST_P384);
        }
        if (i4 == 3) {
            return new zzls(new zzkx("HmacSha512"), zzwq.NIST_P521);
        }
        throw new GeneralSecurityException("invalid curve type: ".concat(String.valueOf(zzwqVar)));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzlg
    public final byte[] zza(byte[] bArr, zzli zzliVar) throws GeneralSecurityException {
        byte[] bArrZza = zzwn.zza(zzwn.zza(this.zza, zzliVar.zza().zzb()), zzwn.zza(this.zza, zzwp.UNCOMPRESSED, bArr));
        byte[] bArrZza2 = zzwi.zza(bArr, zzliVar.zzb().zzb());
        byte[] bArrZza3 = zzlq.zza(zza());
        zzkx zzkxVar = this.zzb;
        return zzkxVar.zza(null, bArrZza, "eae_prk", bArrZza2, "shared_secret", bArrZza3, zzkxVar.zza());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzlg
    public final byte[] zza() throws GeneralSecurityException {
        int i4 = zzlr.zza[this.zza.ordinal()];
        if (i4 == 1) {
            return zzlq.zzc;
        }
        if (i4 == 2) {
            return zzlq.zzd;
        }
        if (i4 == 3) {
            return zzlq.zze;
        }
        throw new GeneralSecurityException("Could not determine HPKE KEM ID");
    }
}
