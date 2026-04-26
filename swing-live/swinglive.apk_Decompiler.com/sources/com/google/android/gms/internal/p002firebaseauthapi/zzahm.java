package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.util.Comparator;
import java.util.Iterator;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzahm implements Serializable, Iterable<Byte> {
    public static final zzahm zza = new zzahw(zzajc.zzb);
    private static final zzaht zzb = new zzahz();
    private static final Comparator<zzahm> zzc = new zzaho();
    private int zzd = 0;

    public static /* synthetic */ int zza(byte b5) {
        return b5 & 255;
    }

    public static zzahm zzb(byte[] bArr) {
        return new zzahw(bArr);
    }

    public static zzahv zzc(int i4) {
        return new zzahv(i4);
    }

    public abstract boolean equals(Object obj);

    public final int hashCode() {
        int iZzb = this.zzd;
        if (iZzb == 0) {
            int iZzb2 = zzb();
            iZzb = zzb(iZzb2, 0, iZzb2);
            if (iZzb == 0) {
                iZzb = 1;
            }
            this.zzd = iZzb;
        }
        return iZzb;
    }

    @Override // java.lang.Iterable
    public /* synthetic */ Iterator<Byte> iterator() {
        return new zzahp(this);
    }

    public final String toString() {
        Locale locale = Locale.ROOT;
        String hexString = Integer.toHexString(System.identityHashCode(this));
        int iZzb = zzb();
        String strZza = zzb() <= 50 ? zzalx.zza(this) : S.f(zzalx.zza(zza(0, 47)), "...");
        StringBuilder sb = new StringBuilder("<ByteString@");
        sb.append(hexString);
        sb.append(" size=");
        sb.append(iZzb);
        sb.append(" contents=\"");
        return S.h(sb, strZza, "\">");
    }

    public abstract byte zza(int i4);

    public abstract zzahm zza(int i4, int i5);

    public abstract String zza(Charset charset);

    public abstract void zza(zzahn zzahnVar);

    public abstract void zza(byte[] bArr, int i4, int i5, int i6);

    public abstract byte zzb(int i4);

    public abstract int zzb();

    public abstract int zzb(int i4, int i5, int i6);

    public abstract zzaib zzc();

    public final String zzd() {
        return zzb() == 0 ? "" : zza(zzajc.zza);
    }

    public final boolean zze() {
        return zzb() == 0;
    }

    public abstract boolean zzf();

    public final byte[] zzg() {
        int iZzb = zzb();
        if (iZzb == 0) {
            return zzajc.zzb;
        }
        byte[] bArr = new byte[iZzb];
        zza(bArr, 0, 0, iZzb);
        return bArr;
    }

    public static int zza(int i4, int i5, int i6) {
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

    public final int zza() {
        return this.zzd;
    }

    public static zzahm zza(byte[] bArr) {
        return zza(bArr, 0, bArr.length);
    }

    public static zzahm zza(byte[] bArr, int i4, int i5) {
        zza(i4, i4 + i5, bArr.length);
        return new zzahw(zzb.zza(bArr, i4, i5));
    }

    public static zzahm zza(String str) {
        return new zzahw(str.getBytes(zzajc.zza));
    }
}
