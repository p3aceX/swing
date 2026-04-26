package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zziw implements zzbq {
    private final zzch<zzbq> zza;
    private final zzrp zzb;
    private final zzrp zzc;

    public zziw(zzch<zzbq> zzchVar) {
        this.zza = zzchVar;
        if (!zzchVar.zzf()) {
            zzrp zzrpVar = zzng.zza;
            this.zzb = zzrpVar;
            this.zzc = zzrpVar;
        } else {
            zzrq zzrqVarZzb = zzno.zza().zzb();
            zzrs zzrsVarZza = zzng.zza(zzchVar);
            this.zzb = zzrqVarZzb.zza(zzrsVarZza, "daead", "encrypt");
            this.zzc = zzrqVarZzb.zza(zzrsVarZza, "daead", "decrypt");
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbq
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length > 5) {
            byte[] bArrCopyOf = Arrays.copyOf(bArr, 5);
            byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 5, bArr.length);
            for (zzcm<zzbq> zzcmVar : this.zza.zza(bArrCopyOf)) {
                try {
                    byte[] bArrZza = zzcmVar.zzf().zza(bArrCopyOfRange, bArr2);
                    this.zzc.zza(zzcmVar.zza(), bArrCopyOfRange.length);
                    return bArrZza;
                } catch (GeneralSecurityException unused) {
                }
            }
        }
        for (zzcm<zzbq> zzcmVar2 : this.zza.zze()) {
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
}
