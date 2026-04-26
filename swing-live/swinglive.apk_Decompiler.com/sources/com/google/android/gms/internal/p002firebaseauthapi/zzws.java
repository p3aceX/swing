package com.google.android.gms.internal.p002firebaseauthapi;

import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class zzws implements zzbh {
    private final zzxk zza;
    private final zzcf zzb;
    private final int zzc;
    private final byte[] zzd;

    private zzws(zzxk zzxkVar, zzcf zzcfVar, int i4, byte[] bArr) {
        this.zza = zzxkVar;
        this.zzb = zzcfVar;
        this.zzc = i4;
        this.zzd = bArr;
    }

    public static zzbh zza(zzdf zzdfVar) {
        return new zzws(new zzwa(zzdfVar.zze().zza(zzbr.zza()), zzdfVar.zzc().zzd()), new zzxo(new zzxm("HMAC".concat(String.valueOf(zzdfVar.zzc().zzg())), new SecretKeySpec(zzdfVar.zzf().zza(zzbr.zza()), "HMAC")), zzdfVar.zzc().zze()), zzdfVar.zzc().zze(), zzdfVar.zzd().zzb());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zzb(byte[] bArr, byte[] bArr2) {
        byte[] bArrZzb = this.zza.zzb(bArr);
        if (bArr2 == null) {
            bArr2 = new byte[0];
        }
        return zzwi.zza(this.zzd, bArrZzb, this.zzb.zza(zzwi.zza(bArr2, bArrZzb, Arrays.copyOf(ByteBuffer.allocate(8).putLong(((long) bArr2.length) * 8).array(), 8))));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        int length = bArr.length;
        int i4 = this.zzc;
        byte[] bArr3 = this.zzd;
        if (length >= i4 + bArr3.length) {
            if (zzpg.zza(bArr3, bArr)) {
                byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, this.zzd.length, bArr.length - this.zzc);
                byte[] bArrCopyOfRange2 = Arrays.copyOfRange(bArr, bArr.length - this.zzc, bArr.length);
                if (bArr2 == null) {
                    bArr2 = new byte[0];
                }
                this.zzb.zza(bArrCopyOfRange2, zzwi.zza(bArr2, bArrCopyOfRange, Arrays.copyOf(ByteBuffer.allocate(8).putLong(((long) bArr2.length) * 8).array(), 8)));
                return this.zza.zza(bArrCopyOfRange);
            }
            throw new GeneralSecurityException("Decryption failed (OutputPrefix mismatch).");
        }
        throw new GeneralSecurityException("Decryption failed (ciphertext too short).");
    }
}
