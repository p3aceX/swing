package com.google.android.recaptcha.internal;

import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzhh extends zzgm {
    public static final /* synthetic */ int zzb = 0;
    private static final Logger zzc = Logger.getLogger(zzhh.class.getName());
    private static final boolean zzd = zzlv.zzx();
    zzhi zza;

    private zzhh() {
    }

    public static zzhh zzA(byte[] bArr, int i4, int i5) {
        return new zzhe(bArr, 0, i5);
    }

    @Deprecated
    public static int zzt(int i4, zzke zzkeVar, zzkr zzkrVar) {
        int iZza = ((zzgf) zzkeVar).zza(zzkrVar);
        int iZzy = zzy(i4 << 3);
        return iZzy + iZzy + iZza;
    }

    public static int zzu(int i4) {
        if (i4 >= 0) {
            return zzy(i4);
        }
        return 10;
    }

    public static int zzv(zzke zzkeVar) {
        int iZzn = zzkeVar.zzn();
        return zzy(iZzn) + iZzn;
    }

    public static int zzw(zzke zzkeVar, zzkr zzkrVar) {
        int iZza = ((zzgf) zzkeVar).zza(zzkrVar);
        return zzy(iZza) + iZza;
    }

    public static int zzx(String str) {
        int length;
        try {
            length = zzma.zzc(str);
        } catch (zzlz unused) {
            length = str.getBytes(zzjc.zzb).length;
        }
        return zzy(length) + length;
    }

    public static int zzy(int i4) {
        if ((i4 & (-128)) == 0) {
            return 1;
        }
        if ((i4 & (-16384)) == 0) {
            return 2;
        }
        if (((-2097152) & i4) == 0) {
            return 3;
        }
        return (i4 & (-268435456)) == 0 ? 4 : 5;
    }

    public static int zzz(long j4) {
        int i4;
        if (((-128) & j4) == 0) {
            return 1;
        }
        if (j4 < 0) {
            return 10;
        }
        if (((-34359738368L) & j4) != 0) {
            j4 >>>= 28;
            i4 = 6;
        } else {
            i4 = 2;
        }
        if (((-2097152) & j4) != 0) {
            j4 >>>= 14;
            i4 += 2;
        }
        return (j4 & (-16384)) != 0 ? i4 + 1 : i4;
    }

    public final void zzB() {
        if (zza() != 0) {
            throw new IllegalStateException("Did not write as much data as expected.");
        }
    }

    public final void zzC(String str, zzlz zzlzVar) throws zzhf {
        zzc.logp(Level.WARNING, "com.google.protobuf.CodedOutputStream", "inefficientWriteStringNoTag", "Converting ill-formed UTF-16. Your Protocol Buffer will not round trip correctly!", (Throwable) zzlzVar);
        byte[] bytes = str.getBytes(zzjc.zzb);
        try {
            int length = bytes.length;
            zzq(length);
            zzl(bytes, 0, length);
        } catch (IndexOutOfBoundsException e) {
            throw new zzhf(e);
        }
    }

    public abstract int zza();

    public abstract void zzb(byte b5);

    public abstract void zzd(int i4, boolean z4);

    public abstract void zze(int i4, zzgw zzgwVar);

    public abstract void zzf(int i4, int i5);

    public abstract void zzg(int i4);

    public abstract void zzh(int i4, long j4);

    public abstract void zzi(long j4);

    public abstract void zzj(int i4, int i5);

    public abstract void zzk(int i4);

    public abstract void zzl(byte[] bArr, int i4, int i5);

    public abstract void zzm(int i4, String str);

    public abstract void zzo(int i4, int i5);

    public abstract void zzp(int i4, int i5);

    public abstract void zzq(int i4);

    public abstract void zzr(int i4, long j4);

    public abstract void zzs(long j4);

    public /* synthetic */ zzhh(zzhg zzhgVar) {
    }
}
