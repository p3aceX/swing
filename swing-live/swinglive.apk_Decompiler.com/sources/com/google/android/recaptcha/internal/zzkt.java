package com.google.android.recaptcha.internal;

import java.util.Iterator;
import java.util.List;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
final class zzkt {
    public static final /* synthetic */ int zza = 0;
    private static final Class zzb;
    private static final zzll zzc;
    private static final zzll zzd;

    static {
        Class<?> cls;
        Class<?> cls2;
        zzll zzllVar = null;
        try {
            cls = Class.forName("com.google.protobuf.GeneratedMessage");
        } catch (Throwable unused) {
            cls = null;
        }
        zzb = cls;
        try {
            cls2 = Class.forName("com.google.protobuf.UnknownFieldSetSchema");
        } catch (Throwable unused2) {
            cls2 = null;
        }
        if (cls2 != null) {
            try {
                zzllVar = (zzll) cls2.getConstructor(new Class[0]).newInstance(new Object[0]);
            } catch (Throwable unused3) {
            }
        }
        zzc = zzllVar;
        zzd = new zzln();
    }

    public static void zzA(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzu(i4, list, z4);
    }

    public static void zzB(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzy(i4, list, z4);
    }

    public static void zzC(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzA(i4, list, z4);
    }

    public static void zzD(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzC(i4, list, z4);
    }

    public static void zzE(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzE(i4, list, z4);
    }

    public static void zzF(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzJ(i4, list, z4);
    }

    public static void zzG(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzL(i4, list, z4);
    }

    public static boolean zzH(Object obj, Object obj2) {
        if (obj != obj2) {
            return obj != null && obj.equals(obj2);
        }
        return true;
    }

    public static int zza(List list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zziu)) {
            int iZzu = 0;
            while (i4 < size) {
                iZzu += zzhh.zzu(((Integer) list.get(i4)).intValue());
                i4++;
            }
            return iZzu;
        }
        zziu zziuVar = (zziu) list;
        int iZzu2 = 0;
        while (i4 < size) {
            iZzu2 += zzhh.zzu(zziuVar.zze(i4));
            i4++;
        }
        return iZzu2;
    }

    public static int zzb(int i4, List list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzhh.zzy(i4 << 3) + 4) * size;
    }

    public static int zzc(List list) {
        return list.size() * 4;
    }

    public static int zzd(int i4, List list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzhh.zzy(i4 << 3) + 8) * size;
    }

    public static int zze(List list) {
        return list.size() * 8;
    }

    public static int zzf(List list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zziu)) {
            int iZzu = 0;
            while (i4 < size) {
                iZzu += zzhh.zzu(((Integer) list.get(i4)).intValue());
                i4++;
            }
            return iZzu;
        }
        zziu zziuVar = (zziu) list;
        int iZzu2 = 0;
        while (i4 < size) {
            iZzu2 += zzhh.zzu(zziuVar.zze(i4));
            i4++;
        }
        return iZzu2;
    }

    public static int zzg(List list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzjt)) {
            int iZzz = 0;
            while (i4 < size) {
                iZzz += zzhh.zzz(((Long) list.get(i4)).longValue());
                i4++;
            }
            return iZzz;
        }
        zzjt zzjtVar = (zzjt) list;
        int iZzz2 = 0;
        while (i4 < size) {
            iZzz2 += zzhh.zzz(zzjtVar.zze(i4));
            i4++;
        }
        return iZzz2;
    }

    public static int zzh(int i4, Object obj, zzkr zzkrVar) {
        int i5 = i4 << 3;
        if (!(obj instanceof zzjk)) {
            return zzhh.zzy(i5) + zzhh.zzw((zzke) obj, zzkrVar);
        }
        int i6 = zzhh.zzb;
        int iZza = ((zzjk) obj).zza();
        return zzhh.zzy(i5) + zzhh.zzy(iZza) + iZza;
    }

    public static int zzi(List list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zziu)) {
            int iZzy = 0;
            while (i4 < size) {
                int iIntValue = ((Integer) list.get(i4)).intValue();
                iZzy += zzhh.zzy((iIntValue >> 31) ^ (iIntValue + iIntValue));
                i4++;
            }
            return iZzy;
        }
        zziu zziuVar = (zziu) list;
        int iZzy2 = 0;
        while (i4 < size) {
            int iZze = zziuVar.zze(i4);
            iZzy2 += zzhh.zzy((iZze >> 31) ^ (iZze + iZze));
            i4++;
        }
        return iZzy2;
    }

    public static int zzj(List list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzjt)) {
            int iZzz = 0;
            while (i4 < size) {
                long jLongValue = ((Long) list.get(i4)).longValue();
                iZzz += zzhh.zzz((jLongValue >> 63) ^ (jLongValue + jLongValue));
                i4++;
            }
            return iZzz;
        }
        zzjt zzjtVar = (zzjt) list;
        int iZzz2 = 0;
        while (i4 < size) {
            long jZze = zzjtVar.zze(i4);
            iZzz2 += zzhh.zzz((jZze >> 63) ^ (jZze + jZze));
            i4++;
        }
        return iZzz2;
    }

    public static int zzk(List list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zziu)) {
            int iZzy = 0;
            while (i4 < size) {
                iZzy += zzhh.zzy(((Integer) list.get(i4)).intValue());
                i4++;
            }
            return iZzy;
        }
        zziu zziuVar = (zziu) list;
        int iZzy2 = 0;
        while (i4 < size) {
            iZzy2 += zzhh.zzy(zziuVar.zze(i4));
            i4++;
        }
        return iZzy2;
    }

    public static int zzl(List list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzjt)) {
            int iZzz = 0;
            while (i4 < size) {
                iZzz += zzhh.zzz(((Long) list.get(i4)).longValue());
                i4++;
            }
            return iZzz;
        }
        zzjt zzjtVar = (zzjt) list;
        int iZzz2 = 0;
        while (i4 < size) {
            iZzz2 += zzhh.zzz(zzjtVar.zze(i4));
            i4++;
        }
        return iZzz2;
    }

    public static zzll zzm() {
        return zzc;
    }

    public static zzll zzn() {
        return zzd;
    }

    public static Object zzo(Object obj, int i4, List list, zzix zzixVar, Object obj2, zzll zzllVar) {
        if (zzixVar == null) {
            return obj2;
        }
        if (!(list instanceof RandomAccess)) {
            Iterator it = list.iterator();
            while (it.hasNext()) {
                int iIntValue = ((Integer) it.next()).intValue();
                if (!zzixVar.zza(iIntValue)) {
                    obj2 = zzp(obj, i4, iIntValue, obj2, zzllVar);
                    it.remove();
                }
            }
            return obj2;
        }
        int size = list.size();
        int i5 = 0;
        for (int i6 = 0; i6 < size; i6++) {
            Integer num = (Integer) list.get(i6);
            int iIntValue2 = num.intValue();
            if (zzixVar.zza(iIntValue2)) {
                if (i6 != i5) {
                    list.set(i5, num);
                }
                i5++;
            } else {
                obj2 = zzp(obj, i4, iIntValue2, obj2, zzllVar);
            }
        }
        if (i5 != size) {
            list.subList(i5, size).clear();
        }
        return obj2;
    }

    public static Object zzp(Object obj, int i4, int i5, Object obj2, zzll zzllVar) {
        if (obj2 == null) {
            obj2 = zzllVar.zzc(obj);
        }
        zzllVar.zzl(obj2, i4, i5);
        return obj2;
    }

    public static void zzq(zzif zzifVar, Object obj, Object obj2) {
        zzij zzijVarZzb = zzifVar.zzb(obj2);
        if (zzijVarZzb.zza.isEmpty()) {
            return;
        }
        zzifVar.zzc(obj).zzh(zzijVarZzb);
    }

    public static void zzr(zzll zzllVar, Object obj, Object obj2) {
        zzllVar.zzo(obj, zzllVar.zze(zzllVar.zzd(obj), zzllVar.zzd(obj2)));
    }

    public static void zzs(Class cls) {
        Class cls2;
        if (!zzit.class.isAssignableFrom(cls) && (cls2 = zzb) != null && !cls2.isAssignableFrom(cls)) {
            throw new IllegalArgumentException("Message classes must extend GeneratedMessage or GeneratedMessageLite");
        }
    }

    public static void zzt(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzc(i4, list, z4);
    }

    public static void zzu(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzg(i4, list, z4);
    }

    public static void zzv(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzj(i4, list, z4);
    }

    public static void zzw(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzl(i4, list, z4);
    }

    public static void zzx(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzn(i4, list, z4);
    }

    public static void zzy(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzp(i4, list, z4);
    }

    public static void zzz(int i4, List list, zzmd zzmdVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzmdVar.zzs(i4, list, z4);
    }
}
