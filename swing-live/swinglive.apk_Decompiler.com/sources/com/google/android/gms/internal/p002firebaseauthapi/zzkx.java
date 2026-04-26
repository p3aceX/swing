package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
final class zzkx implements zzld {
    private final String zza;

    public zzkx(String str) {
        this.zza = str;
    }

    public final int zza() {
        return Mac.getInstance(this.zza).getMacLength();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzld
    public final byte[] zzb() throws GeneralSecurityException {
        String str = this.zza;
        str.getClass();
        switch (str) {
            case "HmacSha256":
                return zzlq.zzf;
            case "HmacSha384":
                return zzlq.zzg;
            case "HmacSha512":
                return zzlq.zzh;
            default:
                throw new GeneralSecurityException("Could not determine HPKE KDF ID");
        }
    }

    private final byte[] zza(byte[] bArr, byte[] bArr2, int i4) throws GeneralSecurityException {
        Mac macZza = zzwr.zzb.zza(this.zza);
        if (i4 > macZza.getMacLength() * 255) {
            throw new GeneralSecurityException("size too large");
        }
        byte[] bArr3 = new byte[i4];
        macZza.init(new SecretKeySpec(bArr, this.zza));
        byte[] bArrDoFinal = new byte[0];
        int i5 = 1;
        int length = 0;
        while (true) {
            macZza.update(bArrDoFinal);
            macZza.update(bArr2);
            macZza.update((byte) i5);
            bArrDoFinal = macZza.doFinal();
            if (bArrDoFinal.length + length >= i4) {
                System.arraycopy(bArrDoFinal, 0, bArr3, length, i4 - length);
                return bArr3;
            }
            System.arraycopy(bArrDoFinal, 0, bArr3, length, bArrDoFinal.length);
            length += bArrDoFinal.length;
            i5++;
        }
    }

    private final byte[] zza(byte[] bArr, byte[] bArr2) throws InvalidKeyException {
        Mac macZza = zzwr.zzb.zza(this.zza);
        if (bArr2 != null && bArr2.length != 0) {
            macZza.init(new SecretKeySpec(bArr2, this.zza));
        } else {
            macZza.init(new SecretKeySpec(new byte[macZza.getMacLength()], this.zza));
        }
        return macZza.doFinal(bArr);
    }

    public final byte[] zza(byte[] bArr, byte[] bArr2, String str, byte[] bArr3, String str2, byte[] bArr4, int i4) {
        return zza(zza(zzlq.zza(str, bArr2, bArr4), null), zzlq.zza(str2, bArr3, bArr4, i4), i4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzld
    public final byte[] zza(byte[] bArr, byte[] bArr2, String str, byte[] bArr3, int i4) {
        return zza(bArr, zzlq.zza(str, bArr2, bArr3, i4), i4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzld
    public final byte[] zza(byte[] bArr, byte[] bArr2, String str, byte[] bArr3) {
        return zza(zzlq.zza(str, bArr2, bArr3), bArr);
    }
}
