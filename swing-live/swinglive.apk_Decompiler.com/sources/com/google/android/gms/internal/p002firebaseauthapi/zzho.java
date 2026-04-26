package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.crypto.tink.shaded.protobuf.S;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.security.GeneralSecurityException;
import java.security.InvalidKeyException;

/* JADX INFO: loaded from: classes.dex */
abstract class zzho {
    int[] zza;
    private final int zzb;

    public zzho(byte[] bArr, int i4) throws InvalidKeyException {
        if (bArr.length != 32) {
            throw new InvalidKeyException("The key length in bytes must be 32.");
        }
        this.zza = zzhk.zza(bArr);
        this.zzb = i4;
    }

    public abstract int zza();

    public final ByteBuffer zza(byte[] bArr, int i4) {
        int[] iArrZza = zza(zzhk.zza(bArr), i4);
        int[] iArr = (int[]) iArrZza.clone();
        zzhk.zza(iArr);
        for (int i5 = 0; i5 < iArrZza.length; i5++) {
            iArrZza[i5] = iArrZza[i5] + iArr[i5];
        }
        ByteBuffer byteBufferOrder = ByteBuffer.allocate(64).order(ByteOrder.LITTLE_ENDIAN);
        byteBufferOrder.asIntBuffer().put(iArrZza, 0, 16);
        return byteBufferOrder;
    }

    public abstract int[] zza(int[] iArr, int i4);

    public void zza(ByteBuffer byteBuffer, byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        if (byteBuffer.remaining() >= bArr2.length) {
            zza(bArr, byteBuffer, ByteBuffer.wrap(bArr2));
            return;
        }
        throw new IllegalArgumentException("Given ByteBuffer output is too small");
    }

    private final void zza(byte[] bArr, ByteBuffer byteBuffer, ByteBuffer byteBuffer2) throws GeneralSecurityException {
        if (bArr.length == zza()) {
            int iRemaining = byteBuffer2.remaining();
            int i4 = iRemaining / 64;
            int i5 = i4 + 1;
            for (int i6 = 0; i6 < i5; i6++) {
                ByteBuffer byteBufferZza = zza(bArr, this.zzb + i6);
                if (i6 == i4) {
                    zzwi.zza(byteBuffer, byteBuffer2, byteBufferZza, iRemaining % 64);
                } else {
                    zzwi.zza(byteBuffer, byteBuffer2, byteBufferZza, 64);
                }
            }
            return;
        }
        throw new GeneralSecurityException(S.d(zza(), "The nonce length (in bytes) must be "));
    }

    public byte[] zza(byte[] bArr, ByteBuffer byteBuffer) throws GeneralSecurityException {
        ByteBuffer byteBufferAllocate = ByteBuffer.allocate(byteBuffer.remaining());
        zza(bArr, byteBufferAllocate, byteBuffer);
        return byteBufferAllocate.array();
    }
}
