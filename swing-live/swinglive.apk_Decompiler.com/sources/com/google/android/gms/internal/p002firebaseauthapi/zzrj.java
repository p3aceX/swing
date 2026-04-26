package com.google.android.gms.internal.p002firebaseauthapi;

import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class zzrj implements zzcf {
    private static final byte[] zza = {0};
    private final zzcf zzb;
    private final zzvt zzc;
    private final byte[] zzd;

    private zzrj(zzcf zzcfVar, zzvt zzvtVar, byte[] bArr) {
        this.zzb = zzcfVar;
        this.zzc = zzvtVar;
        this.zzd = bArr;
    }

    public static zzcf zza(zznc zzncVar) throws GeneralSecurityException {
        byte[] bArrArray;
        zzot zzotVarZza = zzncVar.zza(zzbr.zza());
        zzcf zzcfVar = (zzcf) zzox.zza().zza((zzux) ((zzaja) zzux.zza().zza(zzotVarZza.zzf()).zza(zzotVarZza.zzd()).zza(zzotVarZza.zza()).zzf()), zzcf.class);
        zzvt zzvtVarZzc = zzotVarZza.zzc();
        int i4 = zzrm.zza[zzvtVarZzc.ordinal()];
        if (i4 == 1) {
            bArrArray = new byte[0];
        } else if (i4 == 2 || i4 == 3) {
            bArrArray = ByteBuffer.allocate(5).put((byte) 0).putInt(zzncVar.zza().intValue()).array();
        } else {
            if (i4 != 4) {
                throw new GeneralSecurityException("unknown output prefix type");
            }
            bArrArray = ByteBuffer.allocate(5).put((byte) 1).putInt(zzncVar.zza().intValue()).array();
        }
        return new zzrj(zzcfVar, zzvtVarZzc, bArrArray);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcf
    public final void zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (bArr.length >= 10) {
            if (this.zzc.equals(zzvt.LEGACY)) {
                bArr2 = zzwi.zza(bArr2, zza);
            }
            byte[] bArr3 = new byte[0];
            if (!this.zzc.equals(zzvt.RAW)) {
                byte[] bArrCopyOf = Arrays.copyOf(bArr, 5);
                bArr = Arrays.copyOfRange(bArr, 5, bArr.length);
                bArr3 = bArrCopyOf;
            }
            if (Arrays.equals(this.zzd, bArr3)) {
                this.zzb.zza(bArr, bArr2);
                return;
            }
            throw new GeneralSecurityException("wrong prefix");
        }
        throw new GeneralSecurityException("tag too short");
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcf
    public final byte[] zza(byte[] bArr) throws GeneralSecurityException {
        if (this.zzc.equals(zzvt.LEGACY)) {
            bArr = zzwi.zza(bArr, zza);
        }
        return zzwi.zza(this.zzd, this.zzb.zza(bArr));
    }
}
