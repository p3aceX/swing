package com.google.android.gms.internal.fido;

import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
final class zzbc extends zzbe {
    final char[] zza;

    public zzbc(String str, String str2) {
        zzbb zzbbVar = new zzbb("base16()", "0123456789ABCDEF".toCharArray());
        super(zzbbVar, null);
        this.zza = new char[512];
        zzam.zzc(zzbbVar.zzf.length == 16);
        for (int i4 = 0; i4 < 256; i4++) {
            this.zza[i4] = zzbbVar.zza(i4 >>> 4);
            this.zza[i4 | 256] = zzbbVar.zza(i4 & 15);
        }
    }

    @Override // com.google.android.gms.internal.fido.zzbe, com.google.android.gms.internal.fido.zzbf
    public final void zza(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        zzam.zze(0, i5, bArr.length);
        for (int i6 = 0; i6 < i5; i6++) {
            int i7 = bArr[i6] & 255;
            appendable.append(this.zza[i7]);
            appendable.append(this.zza[i7 | 256]);
        }
    }
}
