package com.google.android.gms.internal.auth;

import B1.a;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.util.Comparator;
import java.util.Iterator;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzef implements Iterable, Serializable {
    private static final Comparator zza;
    public static final zzef zzb = new zzec(zzfa.zzd);
    private static final zzee zzd;
    private int zzc = 0;

    static {
        int i4 = zzds.zza;
        zzd = new zzee(null);
        zza = new zzdx();
    }

    public static int zzi(int i4, int i5, int i6) {
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

    public static zzef zzk(byte[] bArr, int i4, int i5) {
        zzi(i4, i4 + i5, bArr.length);
        byte[] bArr2 = new byte[i5];
        System.arraycopy(bArr, i4, bArr2, 0, i5);
        return new zzec(bArr2);
    }

    public abstract boolean equals(Object obj);

    public final int hashCode() {
        int iZze = this.zzc;
        if (iZze == 0) {
            int iZzd = zzd();
            iZze = zze(iZzd, 0, iZzd);
            if (iZze == 0) {
                iZze = 1;
            }
            this.zzc = iZze;
        }
        return iZze;
    }

    @Override // java.lang.Iterable
    public final /* synthetic */ Iterator iterator() {
        return new zzdw(this);
    }

    public final String toString() {
        Locale locale = Locale.ROOT;
        String hexString = Integer.toHexString(System.identityHashCode(this));
        int iZzd = zzd();
        String strZza = zzd() <= 50 ? zzgx.zza(this) : zzgx.zza(zzf(0, 47)).concat("...");
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

    public abstract int zze(int i4, int i5, int i6);

    public abstract zzef zzf(int i4, int i5);

    public abstract String zzg(Charset charset);

    public abstract boolean zzh();

    public final int zzj() {
        return this.zzc;
    }

    public final String zzl(Charset charset) {
        return zzd() == 0 ? "" : zzg(charset);
    }
}
