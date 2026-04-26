package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
final class zzkl implements zzbp {
    private final zzch<zzbp> zza;
    private final zzrp zzb;

    public zzkl(zzch<zzbp> zzchVar) {
        this.zza = zzchVar;
        if (zzchVar.zzf()) {
            this.zzb = zzno.zza().zzb().zza(zzng.zza(zzchVar), "hybrid_decrypt", "decrypt");
        } else {
            this.zzb = zzng.zza;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbp
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length > 5) {
            byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, 0, 5);
            byte[] bArrCopyOfRange2 = Arrays.copyOfRange(bArr, 5, bArr.length);
            for (zzcm<zzbp> zzcmVar : this.zza.zza(bArrCopyOfRange)) {
                try {
                    byte[] bArrZza = zzcmVar.zzf().zza(bArrCopyOfRange2, bArr2);
                    this.zzb.zza(zzcmVar.zza(), bArrCopyOfRange2.length);
                    return bArrZza;
                } catch (GeneralSecurityException unused) {
                }
            }
        }
        for (zzcm<zzbp> zzcmVar2 : this.zza.zze()) {
            try {
                byte[] bArrZza2 = zzcmVar2.zzf().zza(bArr, bArr2);
                this.zzb.zza(zzcmVar2.zza(), bArr.length);
                return bArrZza2;
            } catch (GeneralSecurityException unused2) {
            }
        }
        this.zzb.zza();
        throw new GeneralSecurityException("decryption failed");
    }
}
