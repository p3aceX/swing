package com.google.android.gms.internal.fido;

import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
final class zzbd extends zzbe {
    public zzbd(String str, String str2, Character ch) {
        zzbb zzbbVar = new zzbb(str, str2.toCharArray());
        super(zzbbVar, ch);
        zzam.zzc(zzbbVar.zzf.length == 64);
    }

    @Override // com.google.android.gms.internal.fido.zzbe, com.google.android.gms.internal.fido.zzbf
    public final void zza(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        int i6 = 0;
        zzam.zze(0, i5, bArr.length);
        for (int i7 = i5; i7 >= 3; i7 -= 3) {
            int i8 = bArr[i6] & 255;
            int i9 = ((bArr[i6 + 1] & 255) << 8) | (i8 << 16) | (bArr[i6 + 2] & 255);
            appendable.append(this.zzb.zza(i9 >>> 18));
            appendable.append(this.zzb.zza((i9 >>> 12) & 63));
            appendable.append(this.zzb.zza((i9 >>> 6) & 63));
            appendable.append(this.zzb.zza(i9 & 63));
            i6 += 3;
        }
        if (i6 < i5) {
            zzc(appendable, bArr, i6, i5 - i6);
        }
    }
}
