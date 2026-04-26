package com.google.android.gms.internal.auth;

/* JADX INFO: loaded from: classes.dex */
final class zzdu {
    public static int zza(byte[] bArr, int i4, zzdt zzdtVar) throws zzfb {
        int iZzh = zzh(bArr, i4, zzdtVar);
        int i5 = zzdtVar.zza;
        if (i5 < 0) {
            throw zzfb.zzc();
        }
        if (i5 > bArr.length - iZzh) {
            throw zzfb.zzf();
        }
        if (i5 == 0) {
            zzdtVar.zzc = zzef.zzb;
            return iZzh;
        }
        zzdtVar.zzc = zzef.zzk(bArr, iZzh, i5);
        return iZzh + i5;
    }

    public static int zzb(byte[] bArr, int i4) {
        int i5 = bArr[i4] & 255;
        int i6 = bArr[i4 + 1] & 255;
        int i7 = bArr[i4 + 2] & 255;
        return ((bArr[i4 + 3] & 255) << 24) | (i6 << 8) | i5 | (i7 << 16);
    }

    public static int zzc(zzgi zzgiVar, byte[] bArr, int i4, int i5, int i6, zzdt zzdtVar) throws zzfb {
        Object objZzd = zzgiVar.zzd();
        int iZzl = zzl(objZzd, zzgiVar, bArr, i4, i5, i6, zzdtVar);
        zzgiVar.zze(objZzd);
        zzdtVar.zzc = objZzd;
        return iZzl;
    }

    public static int zzd(zzgi zzgiVar, byte[] bArr, int i4, int i5, zzdt zzdtVar) throws zzfb {
        Object objZzd = zzgiVar.zzd();
        int iZzm = zzm(objZzd, zzgiVar, bArr, i4, i5, zzdtVar);
        zzgiVar.zze(objZzd);
        zzdtVar.zzc = objZzd;
        return iZzm;
    }

    public static int zze(zzgi zzgiVar, int i4, byte[] bArr, int i5, int i6, zzez zzezVar, zzdt zzdtVar) throws zzfb {
        int iZzd = zzd(zzgiVar, bArr, i5, i6, zzdtVar);
        zzezVar.add(zzdtVar.zzc);
        while (iZzd < i6) {
            int iZzh = zzh(bArr, iZzd, zzdtVar);
            if (i4 != zzdtVar.zza) {
                break;
            }
            iZzd = zzd(zzgiVar, bArr, iZzh, i6, zzdtVar);
            zzezVar.add(zzdtVar.zzc);
        }
        return iZzd;
    }

    public static int zzf(byte[] bArr, int i4, zzez zzezVar, zzdt zzdtVar) throws zzfb {
        zzew zzewVar = (zzew) zzezVar;
        int iZzh = zzh(bArr, i4, zzdtVar);
        int i5 = zzdtVar.zza + iZzh;
        while (iZzh < i5) {
            iZzh = zzh(bArr, iZzh, zzdtVar);
            zzewVar.zze(zzdtVar.zza);
        }
        if (iZzh == i5) {
            return iZzh;
        }
        throw zzfb.zzf();
    }

    public static int zzg(int i4, byte[] bArr, int i5, int i6, zzha zzhaVar, zzdt zzdtVar) throws zzfb {
        if ((i4 >>> 3) == 0) {
            throw zzfb.zza();
        }
        int i7 = i4 & 7;
        if (i7 == 0) {
            int iZzk = zzk(bArr, i5, zzdtVar);
            zzhaVar.zzh(i4, Long.valueOf(zzdtVar.zzb));
            return iZzk;
        }
        if (i7 == 1) {
            zzhaVar.zzh(i4, Long.valueOf(zzn(bArr, i5)));
            return i5 + 8;
        }
        if (i7 == 2) {
            int iZzh = zzh(bArr, i5, zzdtVar);
            int i8 = zzdtVar.zza;
            if (i8 < 0) {
                throw zzfb.zzc();
            }
            if (i8 > bArr.length - iZzh) {
                throw zzfb.zzf();
            }
            if (i8 == 0) {
                zzhaVar.zzh(i4, zzef.zzb);
            } else {
                zzhaVar.zzh(i4, zzef.zzk(bArr, iZzh, i8));
            }
            return iZzh + i8;
        }
        if (i7 != 3) {
            if (i7 != 5) {
                throw zzfb.zza();
            }
            zzhaVar.zzh(i4, Integer.valueOf(zzb(bArr, i5)));
            return i5 + 4;
        }
        int i9 = (i4 & (-8)) | 4;
        zzha zzhaVarZzd = zzha.zzd();
        int i10 = 0;
        while (true) {
            if (i5 >= i6) {
                break;
            }
            int iZzh2 = zzh(bArr, i5, zzdtVar);
            i10 = zzdtVar.zza;
            if (i10 == i9) {
                i5 = iZzh2;
                break;
            }
            i5 = zzg(i10, bArr, iZzh2, i6, zzhaVarZzd, zzdtVar);
        }
        if (i5 > i6 || i10 != i9) {
            throw zzfb.zzd();
        }
        zzhaVar.zzh(i4, zzhaVarZzd);
        return i5;
    }

    public static int zzh(byte[] bArr, int i4, zzdt zzdtVar) {
        int i5 = i4 + 1;
        byte b5 = bArr[i4];
        if (b5 < 0) {
            return zzi(b5, bArr, i5, zzdtVar);
        }
        zzdtVar.zza = b5;
        return i5;
    }

    public static int zzi(int i4, byte[] bArr, int i5, zzdt zzdtVar) {
        byte b5 = bArr[i5];
        int i6 = i5 + 1;
        int i7 = i4 & 127;
        if (b5 >= 0) {
            zzdtVar.zza = i7 | (b5 << 7);
            return i6;
        }
        int i8 = i7 | ((b5 & 127) << 7);
        int i9 = i5 + 2;
        byte b6 = bArr[i6];
        if (b6 >= 0) {
            zzdtVar.zza = i8 | (b6 << 14);
            return i9;
        }
        int i10 = i8 | ((b6 & 127) << 14);
        int i11 = i5 + 3;
        byte b7 = bArr[i9];
        if (b7 >= 0) {
            zzdtVar.zza = i10 | (b7 << 21);
            return i11;
        }
        int i12 = i10 | ((b7 & 127) << 21);
        int i13 = i5 + 4;
        byte b8 = bArr[i11];
        if (b8 >= 0) {
            zzdtVar.zza = i12 | (b8 << 28);
            return i13;
        }
        int i14 = i12 | ((b8 & 127) << 28);
        while (true) {
            int i15 = i13 + 1;
            if (bArr[i13] >= 0) {
                zzdtVar.zza = i14;
                return i15;
            }
            i13 = i15;
        }
    }

    public static int zzj(int i4, byte[] bArr, int i5, int i6, zzez zzezVar, zzdt zzdtVar) {
        zzew zzewVar = (zzew) zzezVar;
        int iZzh = zzh(bArr, i5, zzdtVar);
        zzewVar.zze(zzdtVar.zza);
        while (iZzh < i6) {
            int iZzh2 = zzh(bArr, iZzh, zzdtVar);
            if (i4 != zzdtVar.zza) {
                break;
            }
            iZzh = zzh(bArr, iZzh2, zzdtVar);
            zzewVar.zze(zzdtVar.zza);
        }
        return iZzh;
    }

    public static int zzk(byte[] bArr, int i4, zzdt zzdtVar) {
        long j4 = bArr[i4];
        int i5 = i4 + 1;
        if (j4 >= 0) {
            zzdtVar.zzb = j4;
            return i5;
        }
        int i6 = i4 + 2;
        byte b5 = bArr[i5];
        long j5 = (j4 & 127) | (((long) (b5 & 127)) << 7);
        int i7 = 7;
        while (b5 < 0) {
            int i8 = i6 + 1;
            byte b6 = bArr[i6];
            i7 += 7;
            j5 |= ((long) (b6 & 127)) << i7;
            b5 = b6;
            i6 = i8;
        }
        zzdtVar.zzb = j5;
        return i6;
    }

    public static int zzl(Object obj, zzgi zzgiVar, byte[] bArr, int i4, int i5, int i6, zzdt zzdtVar) throws zzfb {
        int iZzb = ((zzga) zzgiVar).zzb(obj, bArr, i4, i5, i6, zzdtVar);
        zzdtVar.zzc = obj;
        return iZzb;
    }

    public static int zzm(Object obj, zzgi zzgiVar, byte[] bArr, int i4, int i5, zzdt zzdtVar) throws zzfb {
        int iZzi = i4 + 1;
        int i6 = bArr[i4];
        if (i6 < 0) {
            iZzi = zzi(i6, bArr, iZzi, zzdtVar);
            i6 = zzdtVar.zza;
        }
        int i7 = iZzi;
        if (i6 < 0 || i6 > i5 - i7) {
            throw zzfb.zzf();
        }
        int i8 = i7 + i6;
        zzgiVar.zzg(obj, bArr, i7, i8, zzdtVar);
        zzdtVar.zzc = obj;
        return i8;
    }

    public static long zzn(byte[] bArr, int i4) {
        return (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48) | ((((long) bArr[i4 + 7]) & 255) << 56);
    }
}
