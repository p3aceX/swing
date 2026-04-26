package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
final class zzahq extends zzahw {
    private final int zzc;
    private final int zzd;

    public zzahq(byte[] bArr, int i4, int i5) {
        super(bArr);
        zzahm.zza(i4, i4 + i5, bArr.length);
        this.zzc = i4;
        this.zzd = i5;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahw, com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final byte zza(int i4) {
        int iZzb = zzb();
        if (((iZzb - (i4 + 1)) | i4) >= 0) {
            return this.zzb[this.zzc + i4];
        }
        if (i4 < 0) {
            throw new ArrayIndexOutOfBoundsException(S.d(i4, "Index < 0: "));
        }
        throw new ArrayIndexOutOfBoundsException(a.k("Index > length: ", i4, iZzb, ", "));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahw, com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final byte zzb(int i4) {
        return this.zzb[this.zzc + i4];
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahw
    public final int zzh() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahw, com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final int zzb() {
        return this.zzd;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzahw, com.google.android.gms.internal.p002firebaseauthapi.zzahm
    public final void zza(byte[] bArr, int i4, int i5, int i6) {
        System.arraycopy(this.zzb, zzh(), bArr, 0, i6);
    }
}
