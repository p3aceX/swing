package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;

/* JADX INFO: loaded from: classes.dex */
final class zzkv implements zzla {
    private final int zza;

    public zzkv(int i4) throws InvalidAlgorithmParameterException {
        if (i4 != 16 && i4 != 32) {
            throw new InvalidAlgorithmParameterException(S.d(i4, "Unsupported key length: "));
        }
        this.zza = i4;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzla
    public final int zza() {
        return this.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzla
    public final int zzb() {
        return 12;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzla
    public final byte[] zzc() throws GeneralSecurityException {
        int i4 = this.zza;
        if (i4 == 16) {
            return zzlq.zzi;
        }
        if (i4 == 32) {
            return zzlq.zzj;
        }
        throw new GeneralSecurityException("Could not determine HPKE AEAD ID");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzla
    public final byte[] zza(byte[] bArr, byte[] bArr2, byte[] bArr3, byte[] bArr4) throws InvalidAlgorithmParameterException {
        if (bArr.length == this.zza) {
            return new zzhn(bArr, false).zza(bArr2, bArr3, bArr4);
        }
        throw new InvalidAlgorithmParameterException(S.d(bArr.length, "Unexpected key length: "));
    }
}
