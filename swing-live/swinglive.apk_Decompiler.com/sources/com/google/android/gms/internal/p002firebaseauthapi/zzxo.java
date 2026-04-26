package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzpp;
import com.google.android.gms.internal.p002firebaseauthapi.zzqm;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.MessageDigest;
import java.util.Arrays;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class zzxo implements zzcf {
    private static final byte[] zza = {0};
    private final zzrv zzb;
    private final int zzc;
    private final byte[] zzd;
    private final byte[] zze;

    private zzxo(zzpi zzpiVar) {
        this.zzb = new zzxj(zzpiVar.zze().zza(zzbr.zza()));
        this.zzc = ((zzpp) zzpiVar.zzc()).zzb();
        this.zzd = zzpiVar.zzd().zzb();
        if (!((zzpp) zzpiVar.zzc()).zze().equals(zzpp.zzb.zzc)) {
            this.zze = new byte[0];
        } else {
            byte[] bArr = zza;
            this.zze = Arrays.copyOf(bArr, bArr.length);
        }
    }

    public static zzcf zza(zzpi zzpiVar) {
        return new zzxo(zzpiVar);
    }

    public static zzcf zza(zzqb zzqbVar) {
        return new zzxo(zzqbVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcf
    public final void zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (!MessageDigest.isEqual(zza(bArr2), bArr)) {
            throw new GeneralSecurityException("invalid MAC");
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcf
    public final byte[] zza(byte[] bArr) {
        byte[] bArr2 = this.zze;
        if (bArr2.length > 0) {
            return zzwi.zza(this.zzd, this.zzb.zza(zzwi.zza(bArr, bArr2), this.zzc));
        }
        return zzwi.zza(this.zzd, this.zzb.zza(bArr, this.zzc));
    }

    private zzxo(zzqb zzqbVar) {
        this.zzb = new zzxm("HMAC".concat(String.valueOf(((zzqm) zzqbVar.zzc()).zze())), new SecretKeySpec(zzqbVar.zze().zza(zzbr.zza()), "HMAC"));
        this.zzc = ((zzqm) zzqbVar.zzc()).zzb();
        this.zzd = zzqbVar.zzd().zzb();
        if (((zzqm) zzqbVar.zzc()).zzf().equals(zzqm.zzc.zzc)) {
            byte[] bArr = zza;
            this.zze = Arrays.copyOf(bArr, bArr.length);
        } else {
            this.zze = new byte[0];
        }
    }

    public zzxo(zzrv zzrvVar, int i4) throws InvalidAlgorithmParameterException {
        this.zzb = zzrvVar;
        this.zzc = i4;
        this.zzd = new byte[0];
        this.zze = new byte[0];
        if (i4 >= 10) {
            zzrvVar.zza(new byte[0], i4);
            return;
        }
        throw new InvalidAlgorithmParameterException("tag size too small, need at least 10 bytes");
    }
}
