package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zzqt implements zzcf {
    private final zzch<zzcf> zza;
    private final zzrp zzb;
    private final zzrp zzc;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcf
    public final void zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length <= 5) {
            this.zzc.zza();
            throw new GeneralSecurityException("tag too short");
        }
        for (zzcm<zzcf> zzcmVar : this.zza.zza(Arrays.copyOf(bArr, 5))) {
            try {
                zzcmVar.zze().zza(bArr, bArr2);
                this.zzc.zza(zzcmVar.zza(), bArr2.length);
                return;
            } catch (GeneralSecurityException unused) {
            }
        }
        for (zzcm<zzcf> zzcmVar2 : this.zza.zze()) {
            try {
                zzcmVar2.zze().zza(bArr, bArr2);
                this.zzc.zza(zzcmVar2.zza(), bArr2.length);
                return;
            } catch (GeneralSecurityException unused2) {
            }
        }
        this.zzc.zza();
        throw new GeneralSecurityException("invalid MAC");
    }

    private zzqt(zzch<zzcf> zzchVar) {
        this.zza = zzchVar;
        if (!zzchVar.zzf()) {
            zzrp zzrpVar = zzng.zza;
            this.zzb = zzrpVar;
            this.zzc = zzrpVar;
        } else {
            zzrq zzrqVarZzb = zzno.zza().zzb();
            zzrs zzrsVarZza = zzng.zza(zzchVar);
            this.zzb = zzrqVarZzb.zza(zzrsVarZza, "mac", "compute");
            this.zzc = zzrqVarZzb.zza(zzrsVarZza, "mac", "verify");
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcf
    public final byte[] zza(byte[] bArr) throws GeneralSecurityException {
        try {
            byte[] bArrZza = this.zza.zza().zze().zza(bArr);
            this.zzb.zza(this.zza.zza().zza(), bArr.length);
            return bArrZza;
        } catch (GeneralSecurityException e) {
            this.zzb.zza();
            throw e;
        }
    }
}
