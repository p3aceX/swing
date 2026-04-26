package com.google.android.gms.internal.fido;

import java.io.IOException;
import java.math.RoundingMode;

/* JADX INFO: loaded from: classes.dex */
class zzbe extends zzbf {
    final zzbb zzb;
    final Character zzc;

    public zzbe(zzbb zzbbVar, Character ch) {
        this.zzb = zzbbVar;
        if (ch != null && zzbbVar.zzb('=')) {
            throw new IllegalArgumentException(zzan.zza("Padding character %s was already in alphabet", ch));
        }
        this.zzc = ch;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof zzbe) {
            zzbe zzbeVar = (zzbe) obj;
            if (this.zzb.equals(zzbeVar.zzb)) {
                Character ch = this.zzc;
                Character ch2 = zzbeVar.zzc;
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
        int iHashCode = this.zzb.hashCode();
        Character ch = this.zzc;
        return iHashCode ^ (ch == null ? 0 : ch.hashCode());
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

    @Override // com.google.android.gms.internal.fido.zzbf
    public void zza(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        int i6 = 0;
        zzam.zze(0, i5, bArr.length);
        while (i6 < i5) {
            zzc(appendable, bArr, i6, Math.min(this.zzb.zzd, i5 - i6));
            i6 += this.zzb.zzd;
        }
    }

    @Override // com.google.android.gms.internal.fido.zzbf
    public final int zzb(int i4) {
        zzbb zzbbVar = this.zzb;
        return zzbh.zza(i4, zzbbVar.zzd, RoundingMode.CEILING) * zzbbVar.zzc;
    }

    public final void zzc(Appendable appendable, byte[] bArr, int i4, int i5) throws IOException {
        zzam.zze(i4, i4 + i5, bArr.length);
        int i6 = 0;
        zzam.zzc(i5 <= this.zzb.zzd);
        long j4 = 0;
        for (int i7 = 0; i7 < i5; i7++) {
            j4 = (j4 | ((long) (bArr[i4 + i7] & 255))) << 8;
        }
        int i8 = ((i5 + 1) * 8) - this.zzb.zzb;
        while (i6 < i5 * 8) {
            zzbb zzbbVar = this.zzb;
            appendable.append(zzbbVar.zza(zzbbVar.zza & ((int) (j4 >>> (i8 - i6)))));
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

    public zzbe(String str, String str2, Character ch) {
        this(new zzbb(str, str2.toCharArray()), ch);
    }
}
