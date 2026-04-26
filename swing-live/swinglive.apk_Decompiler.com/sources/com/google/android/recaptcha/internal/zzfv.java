package com.google.android.recaptcha.internal;

import com.google.crypto.tink.shaded.protobuf.S;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
final class zzfv extends zzfx {
    public zzfv(String str, String str2, Character ch) {
        zzft zzftVar = new zzft(str, str2.toCharArray());
        super(zzftVar, ch);
        zzff.zza(zzftVar.zzf.length == 64);
    }

    @Override // com.google.android.recaptcha.internal.zzfx, com.google.android.recaptcha.internal.zzfy
    public final int zza(byte[] bArr, CharSequence charSequence) throws zzfw {
        CharSequence charSequenceZze = zze(charSequence);
        if (!this.zzb.zzc(charSequenceZze.length())) {
            throw new zzfw(S.d(charSequenceZze.length(), "Invalid input length "));
        }
        int i4 = 0;
        int i5 = 0;
        while (i4 < charSequenceZze.length()) {
            int i6 = i5 + 1;
            int iZzb = (this.zzb.zzb(charSequenceZze.charAt(i4)) << 18) | (this.zzb.zzb(charSequenceZze.charAt(i4 + 1)) << 12);
            bArr[i5] = (byte) (iZzb >>> 16);
            int i7 = i4 + 2;
            if (i7 < charSequenceZze.length()) {
                int i8 = i4 + 3;
                int iZzb2 = iZzb | (this.zzb.zzb(charSequenceZze.charAt(i7)) << 6);
                int i9 = i5 + 2;
                bArr[i6] = (byte) ((iZzb2 >>> 8) & 255);
                if (i8 < charSequenceZze.length()) {
                    i4 += 4;
                    i5 += 3;
                    bArr[i9] = (byte) ((iZzb2 | this.zzb.zzb(charSequenceZze.charAt(i8))) & 255);
                } else {
                    i5 = i9;
                    i4 = i8;
                }
            } else {
                i4 = i7;
                i5 = i6;
            }
        }
        return i5;
    }

    @Override // com.google.android.recaptcha.internal.zzfx, com.google.android.recaptcha.internal.zzfy
    public final void zzb(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        int i6 = 0;
        zzff.zzd(0, i5, bArr.length);
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
            zzf(appendable, bArr, i6, i5 - i6);
        }
    }
}
