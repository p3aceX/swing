package com.google.android.recaptcha.internal;

import com.google.crypto.tink.shaded.protobuf.S;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
final class zzfu extends zzfx {
    final char[] zza;

    public zzfu(String str, String str2) {
        zzft zzftVar = new zzft("base16()", "0123456789ABCDEF".toCharArray());
        super(zzftVar, null);
        this.zza = new char[512];
        zzff.zza(zzftVar.zzf.length == 16);
        for (int i4 = 0; i4 < 256; i4++) {
            this.zza[i4] = zzftVar.zza(i4 >>> 4);
            this.zza[i4 | 256] = zzftVar.zza(i4 & 15);
        }
    }

    @Override // com.google.android.recaptcha.internal.zzfx, com.google.android.recaptcha.internal.zzfy
    public final int zza(byte[] bArr, CharSequence charSequence) throws zzfw {
        if (charSequence.length() % 2 == 1) {
            throw new zzfw(S.d(charSequence.length(), "Invalid input length "));
        }
        int i4 = 0;
        int i5 = 0;
        while (i4 < charSequence.length()) {
            bArr[i5] = (byte) ((this.zzb.zzb(charSequence.charAt(i4)) << 4) | this.zzb.zzb(charSequence.charAt(i4 + 1)));
            i4 += 2;
            i5++;
        }
        return i5;
    }

    @Override // com.google.android.recaptcha.internal.zzfx, com.google.android.recaptcha.internal.zzfy
    public final void zzb(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        zzff.zzd(0, i5, bArr.length);
        for (int i6 = 0; i6 < i5; i6++) {
            int i7 = bArr[i6] & 255;
            appendable.append(this.zza[i7]);
            appendable.append(this.zza[i7 | 256]);
        }
    }
}
