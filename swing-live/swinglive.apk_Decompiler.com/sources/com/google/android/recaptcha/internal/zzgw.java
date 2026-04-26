package com.google.android.recaptcha.internal;

import B1.a;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.util.Comparator;
import java.util.Iterator;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzgw implements Iterable, Serializable {
    private static final Comparator zza;
    public static final zzgw zzb = new zzgt(zzjc.zzd);
    private static final zzgv zzd;
    private int zzc = 0;

    static {
        int i4 = zzgi.zza;
        zzd = new zzgv(null);
        zza = new zzgo();
    }

    public static int zzk(int i4, int i5, int i6) {
        int i7 = i5 - i4;
        if ((i4 | i5 | i7 | (i6 - i5)) >= 0) {
            return i7;
        }
        if (i4 < 0) {
            throw new IndexOutOfBoundsException(a.l("Beginning index: ", i4, " < 0"));
        }
        if (i5 < i4) {
            throw new IndexOutOfBoundsException(a.k("Beginning index larger than ending index: ", i4, i5, ", "));
        }
        throw new IndexOutOfBoundsException(a.k("End index: ", i5, i6, " >= "));
    }

    public static zzgw zzm(byte[] bArr, int i4, int i5) {
        zzk(i4, i4 + i5, bArr.length);
        byte[] bArr2 = new byte[i5];
        System.arraycopy(bArr, i4, bArr2, 0, i5);
        return new zzgt(bArr2);
    }

    public abstract boolean equals(Object obj);

    public final int hashCode() {
        int iZzf = this.zzc;
        if (iZzf == 0) {
            int iZzd = zzd();
            iZzf = zzf(iZzd, 0, iZzd);
            if (iZzf == 0) {
                iZzf = 1;
            }
            this.zzc = iZzf;
        }
        return iZzf;
    }

    @Override // java.lang.Iterable
    public final /* synthetic */ Iterator iterator() {
        return new zzgn(this);
    }

    public final String toString() {
        Locale locale = Locale.ROOT;
        String hexString = Integer.toHexString(System.identityHashCode(this));
        int iZzd = zzd();
        String strZza = zzd() <= 50 ? zzlg.zza(this) : zzlg.zza(zzg(0, 47)).concat("...");
        StringBuilder sb = new StringBuilder("<ByteString@");
        sb.append(hexString);
        sb.append(" size=");
        sb.append(iZzd);
        sb.append(" contents=\"");
        return S.h(sb, strZza, "\">");
    }

    public abstract byte zza(int i4);

    public abstract byte zzb(int i4);

    public abstract int zzd();

    public abstract void zze(byte[] bArr, int i4, int i5, int i6);

    public abstract int zzf(int i4, int i5, int i6);

    public abstract zzgw zzg(int i4, int i5);

    public abstract String zzh(Charset charset);

    public abstract void zzi(zzgm zzgmVar);

    public abstract boolean zzj();

    public final int zzl() {
        return this.zzc;
    }

    public final String zzn(Charset charset) {
        return zzd() == 0 ? "" : zzh(charset);
    }

    public final byte[] zzo() {
        int iZzd = zzd();
        if (iZzd == 0) {
            return zzjc.zzd;
        }
        byte[] bArr = new byte[iZzd];
        zze(bArr, 0, 0, iZzd);
        return bArr;
    }
}
