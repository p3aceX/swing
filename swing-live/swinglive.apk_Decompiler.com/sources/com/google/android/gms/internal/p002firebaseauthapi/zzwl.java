package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.security.interfaces.ECPrivateKey;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/* JADX INFO: loaded from: classes.dex */
public final class zzwl {
    private ECPrivateKey zza;

    public zzwl(ECPrivateKey eCPrivateKey) {
        this.zza = eCPrivateKey;
    }

    public final byte[] zza(byte[] bArr, String str, byte[] bArr2, byte[] bArr3, int i4, zzwp zzwpVar) throws GeneralSecurityException {
        byte[] bArrZza = zzwi.zza(bArr, zzwn.zza(this.zza, zzwn.zza(this.zza.getParams(), zzwpVar, bArr)));
        Mac macZza = zzwr.zzb.zza(str);
        if (i4 > macZza.getMacLength() * 255) {
            throw new GeneralSecurityException("size too large");
        }
        if (bArr2 == null || bArr2.length == 0) {
            macZza.init(new SecretKeySpec(new byte[macZza.getMacLength()], str));
        } else {
            macZza.init(new SecretKeySpec(bArr2, str));
        }
        byte[] bArr4 = new byte[i4];
        macZza.init(new SecretKeySpec(macZza.doFinal(bArrZza), str));
        byte[] bArrDoFinal = new byte[0];
        int i5 = 1;
        int length = 0;
        while (true) {
            macZza.update(bArrDoFinal);
            macZza.update(bArr3);
            macZza.update((byte) i5);
            bArrDoFinal = macZza.doFinal();
            if (bArrDoFinal.length + length >= i4) {
                System.arraycopy(bArrDoFinal, 0, bArr4, length, i4 - length);
                return bArr4;
            }
            System.arraycopy(bArrDoFinal, 0, bArr4, length, bArrDoFinal.length);
            length += bArrDoFinal.length;
            i5++;
        }
    }
}
