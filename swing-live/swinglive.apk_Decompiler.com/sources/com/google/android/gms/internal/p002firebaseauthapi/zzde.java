package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zzde implements zzbh {
    private final zzch<zzbh> zza;
    private final zzrp zzb;
    private final zzrp zzc;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length > 5) {
            byte[] bArrCopyOf = Arrays.copyOf(bArr, 5);
            byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 5, bArr.length);
            for (zzcm<zzbh> zzcmVar : this.zza.zza(bArrCopyOf)) {
                try {
                    byte[] bArrZza = zzcmVar.zzf().zza(bArrCopyOfRange, bArr2);
                    this.zzc.zza(zzcmVar.zza(), bArrCopyOfRange.length);
                    return bArrZza;
                } catch (GeneralSecurityException unused) {
                }
            }
        }
        for (zzcm<zzbh> zzcmVar2 : this.zza.zze()) {
            try {
                byte[] bArrZza2 = zzcmVar2.zzf().zza(bArr, bArr2);
                this.zzc.zza(zzcmVar2.zza(), bArr.length);
                return bArrZza2;
            } catch (GeneralSecurityException unused2) {
            }
        }
        this.zzc.zza();
        throw new GeneralSecurityException("decryption failed");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zzb(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        try {
            byte[] bArrZza = zzwi.zza(this.zza.zza().zzh(), this.zza.zza().zzf().zzb(bArr, bArr2));
            this.zzb.zza(this.zza.zza().zza(), bArr.length);
            return bArrZza;
        } catch (GeneralSecurityException e) {
            this.zzb.zza();
            throw e;
        }
    }

    private zzde(zzch<zzbh> zzchVar) {
        this.zza = zzchVar;
        if (!zzchVar.zzf()) {
            zzrp zzrpVar = zzng.zza;
            this.zzb = zzrpVar;
            this.zzc = zzrpVar;
        } else {
            zzrq zzrqVarZzb = zzno.zza().zzb();
            zzrs zzrsVarZza = zzng.zza(zzchVar);
            this.zzb = zzrqVarZzb.zza(zzrsVarZza, "aead", "encrypt");
            this.zzc = zzrqVarZzb.zza(zzrsVarZza, "aead", "decrypt");
        }
    }
}
