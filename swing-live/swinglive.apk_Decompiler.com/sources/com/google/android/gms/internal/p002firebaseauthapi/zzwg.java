package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzic;
import com.google.crypto.tink.shaded.protobuf.S;
import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzwg implements zzbh {
    private static final zzic.zza zza = zzic.zza.zzb;
    private final zzhn zzb;
    private final byte[] zzc;

    private zzwg(byte[] bArr, zzxr zzxrVar) throws GeneralSecurityException {
        if (!zza.zza()) {
            throw new GeneralSecurityException("Can not use AES-GCM in FIPS-mode, as BoringCrypto module is not available.");
        }
        this.zzb = new zzhn(bArr, true);
        this.zzc = zzxrVar.zzb();
    }

    public static zzbh zza(zzek zzekVar) throws GeneralSecurityException {
        if (zzekVar.zzc().zzb() != 12) {
            throw new GeneralSecurityException(S.d(zzekVar.zzc().zzb(), "Expected IV Size 12, got "));
        }
        if (zzekVar.zzc().zzd() == 16) {
            return new zzwg(zzekVar.zze().zza(zzbr.zza()), zzekVar.zzd());
        }
        throw new GeneralSecurityException(S.d(zzekVar.zzc().zzd(), "Expected tag Size 16, got "));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zzb(byte[] bArr, byte[] bArr2) {
        byte[] bArrZza = zzov.zza(12);
        byte[] bArr3 = this.zzc;
        return bArr3.length == 0 ? this.zzb.zzb(bArrZza, bArr, bArr2) : zzwi.zza(bArr3, this.zzb.zzb(bArrZza, bArr, bArr2));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbh
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        byte[] bArr3 = this.zzc;
        if (bArr3.length == 0) {
            return this.zzb.zza(Arrays.copyOf(bArr, 12), bArr, bArr2);
        }
        if (zzpg.zza(bArr3, bArr)) {
            byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, this.zzc.length, bArr.length);
            return this.zzb.zza(Arrays.copyOf(bArrCopyOfRange, 12), bArrCopyOfRange, bArr2);
        }
        throw new GeneralSecurityException("Decryption failed (OutputPrefix mismatch).");
    }
}
