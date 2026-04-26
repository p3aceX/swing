package com.google.android.recaptcha.internal;

import com.google.crypto.tink.shaded.protobuf.S;
import java.io.IOException;
import java.math.RoundingMode;

/* JADX INFO: loaded from: classes.dex */
class zzfx extends zzfy {
    final zzft zzb;
    final Character zzc;

    public zzfx(zzft zzftVar, Character ch) {
        this.zzb = zzftVar;
        if (ch != null && zzftVar.zzd('=')) {
            throw new IllegalArgumentException(zzfi.zza("Padding character %s was already in alphabet", ch));
        }
        this.zzc = ch;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof zzfx) {
            zzfx zzfxVar = (zzfx) obj;
            if (this.zzb.equals(zzfxVar.zzb)) {
                Character ch = this.zzc;
                Character ch2 = zzfxVar.zzc;
                if (ch == ch2) {
                    return true;
                }
                if (ch != null && ch.equals(ch2)) {
                    return true;
                }
            }
        }
        return false;
    }

    public final int hashCode() {
        Character ch = this.zzc;
        return (ch == null ? 0 : ch.hashCode()) ^ this.zzb.hashCode();
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("BaseEncoding.");
        sb.append(this.zzb);
        if (8 % this.zzb.zzb != 0) {
            if (this.zzc == null) {
                sb.append(".omitPadding()");
            } else {
                sb.append(".withPadChar('");
                sb.append(this.zzc);
                sb.append("')");
            }
        }
        return sb.toString();
    }

    @Override // com.google.android.recaptcha.internal.zzfy
    public int zza(byte[] bArr, CharSequence charSequence) throws zzfw {
        zzft zzftVar;
        CharSequence charSequenceZze = zze(charSequence);
        if (!this.zzb.zzc(charSequenceZze.length())) {
            throw new zzfw(S.d(charSequenceZze.length(), "Invalid input length "));
        }
        int i4 = 0;
        int i5 = 0;
        while (i4 < charSequenceZze.length()) {
            long jZzb = 0;
            int i6 = 0;
            int i7 = 0;
            while (true) {
                zzftVar = this.zzb;
                if (i6 >= zzftVar.zzc) {
                    break;
                }
                jZzb <<= zzftVar.zzb;
                if (i4 + i6 < charSequenceZze.length()) {
                    jZzb |= (long) this.zzb.zzb(charSequenceZze.charAt(i7 + i4));
                    i7++;
                }
                i6++;
            }
            int i8 = zzftVar.zzd;
            int i9 = i7 * zzftVar.zzb;
            int i10 = (i8 - 1) * 8;
            while (i10 >= (i8 * 8) - i9) {
                bArr[i5] = (byte) ((jZzb >>> i10) & 255);
                i10 -= 8;
                i5++;
            }
            i4 += this.zzb.zzc;
        }
        return i5;
    }

    @Override // com.google.android.recaptcha.internal.zzfy
    public void zzb(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        int i6 = 0;
        zzff.zzd(0, i5, bArr.length);
        while (i6 < i5) {
            zzf(appendable, bArr, i6, Math.min(this.zzb.zzd, i5 - i6));
            i6 += this.zzb.zzd;
        }
    }

    @Override // com.google.android.recaptcha.internal.zzfy
    public final int zzc(int i4) {
        return (int) (((((long) this.zzb.zzb) * ((long) i4)) + 7) / 8);
    }

    @Override // com.google.android.recaptcha.internal.zzfy
    public final int zzd(int i4) {
        zzft zzftVar = this.zzb;
        return zzftVar.zzc * zzga.zza(i4, zzftVar.zzd, RoundingMode.CEILING);
    }

    @Override // com.google.android.recaptcha.internal.zzfy
    public final CharSequence zze(CharSequence charSequence) {
        charSequence.getClass();
        if (this.zzc == null) {
            return charSequence;
        }
        int length = charSequence.length();
        do {
            length--;
            if (length < 0) {
                break;
            }
        } while (charSequence.charAt(length) == '=');
        return charSequence.subSequence(0, length + 1);
    }

    public final void zzf(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        zzff.zzd(i4, i4 + i5, bArr.length);
        int i6 = 0;
        zzff.zza(i5 <= this.zzb.zzd);
        long j4 = 0;
        for (int i7 = 0; i7 < i5; i7++) {
            j4 = (j4 | ((long) (bArr[i4 + i7] & 255))) << 8;
        }
        int i8 = (i5 + 1) * 8;
        zzft zzftVar = this.zzb;
        while (i6 < i5 * 8) {
            long j5 = j4 >>> ((i8 - zzftVar.zzb) - i6);
            zzft zzftVar2 = this.zzb;
            appendable.append(zzftVar2.zza(((int) j5) & zzftVar2.zza));
            i6 += this.zzb.zzb;
        }
        if (this.zzc != null) {
            while (i6 < this.zzb.zzd * 8) {
                this.zzc.getClass();
                appendable.append('=');
                i6 += this.zzb.zzb;
            }
        }
    }

    public zzfx(String str, String str2, Character ch) {
        this(new zzft(str, str2.toCharArray()), ch);
    }
}
