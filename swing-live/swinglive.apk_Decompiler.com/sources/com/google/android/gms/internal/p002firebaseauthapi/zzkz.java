package com.google.android.gms.internal.p002firebaseauthapi;

import java.math.BigInteger;
import java.security.GeneralSecurityException;

/* JADX INFO: loaded from: classes.dex */
public final class zzkz {
    private static final byte[] zza = new byte[0];
    private final zzla zzb;
    private final BigInteger zzc;
    private final byte[] zzd;
    private final byte[] zze;
    private final byte[] zzf;
    private BigInteger zzg = BigInteger.ZERO;

    private zzkz(byte[] bArr, byte[] bArr2, byte[] bArr3, BigInteger bigInteger, zzla zzlaVar) {
        this.zzf = bArr;
        this.zzd = bArr2;
        this.zze = bArr3;
        this.zzc = bigInteger;
        this.zzb = zzlaVar;
    }

    public static zzkz zza(byte[] bArr, zzli zzliVar, zzlg zzlgVar, zzld zzldVar, zzla zzlaVar, byte[] bArr2) throws GeneralSecurityException {
        byte[] bArrZza = zzlgVar.zza(bArr, zzliVar);
        byte[] bArr3 = zzlq.zza;
        byte[] bArrZza2 = zzlq.zza(zzlgVar.zza(), zzldVar.zzb(), zzlaVar.zzc());
        byte[] bArr4 = zzlq.zzl;
        byte[] bArr5 = zza;
        byte[] bArrZza3 = zzwi.zza(bArr3, zzldVar.zza(bArr4, bArr5, "psk_id_hash", bArrZza2), zzldVar.zza(bArr4, bArr2, "info_hash", bArrZza2));
        byte[] bArrZza4 = zzldVar.zza(bArrZza, bArr5, "secret", bArrZza2);
        byte[] bArrZza5 = zzldVar.zza(bArrZza4, bArrZza3, "key", bArrZza2, zzlaVar.zza());
        byte[] bArrZza6 = zzldVar.zza(bArrZza4, bArrZza3, "base_nonce", bArrZza2, zzlaVar.zzb());
        zzlaVar.zzb();
        BigInteger bigInteger = BigInteger.ONE;
        return new zzkz(bArr, bArrZza5, bArrZza6, bigInteger.shiftLeft(96).subtract(bigInteger), zzlaVar);
    }

    private final synchronized byte[] zza() {
        byte[] bArrZza;
        bArrZza = zzwi.zza(this.zze, zzmb.zza(this.zzg, this.zzb.zzb()));
        if (this.zzg.compareTo(this.zzc) < 0) {
            this.zzg = this.zzg.add(BigInteger.ONE);
        } else {
            throw new GeneralSecurityException("message limit reached");
        }
        return bArrZza;
    }

    public final byte[] zza(byte[] bArr, byte[] bArr2) {
        return this.zzb.zza(this.zzd, zza(), bArr, bArr2);
    }
}
