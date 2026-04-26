package com.google.android.recaptcha.internal;

import B1.a;
import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
final class zzgq extends zzgt {
    private final int zzc;

    public zzgq(byte[] bArr, int i4, int i5) {
        super(bArr);
        zzgw.zzk(0, i5, bArr.length);
        this.zzc = i5;
    }

    @Override // com.google.android.recaptcha.internal.zzgt, com.google.android.recaptcha.internal.zzgw
    public final byte zza(int i4) {
        int i5 = this.zzc;
        if (((i5 - (i4 + 1)) | i4) >= 0) {
            return this.zza[i4];
        }
        if (i4 < 0) {
            throw new ArrayIndexOutOfBoundsException(S.d(i4, "Index < 0: "));
        }
        throw new ArrayIndexOutOfBoundsException(a.k("Index > length: ", i4, i5, ", "));
    }

    @Override // com.google.android.recaptcha.internal.zzgt, com.google.android.recaptcha.internal.zzgw
    public final byte zzb(int i4) {
        return this.zza[i4];
    }

    @Override // com.google.android.recaptcha.internal.zzgt
    public final int zzc() {
        return 0;
    }

    @Override // com.google.android.recaptcha.internal.zzgt, com.google.android.recaptcha.internal.zzgw
    public final int zzd() {
        return this.zzc;
    }

    @Override // com.google.android.recaptcha.internal.zzgt, com.google.android.recaptcha.internal.zzgw
    public final void zze(byte[] bArr, int i4, int i5, int i6) {
        System.arraycopy(this.zza, 0, bArr, 0, i6);
    }
}
