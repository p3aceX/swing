package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.List;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
final class zzale {
    private static final Class<?> zza = zzd();
    private static final zzamb<?, ?> zzb = zzc();
    private static final zzamb<?, ?> zzc = new zzamd();

    public static int zza(int i4, List<?> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return zzaii.zza(i4, true) * size;
    }

    public static int zzb(int i4, List<Integer> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzaii.zzg(i4) * size) + zzb(list);
    }

    public static int zzc(int i4, List<?> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return zzaii.zzb(i4, 0) * size;
    }

    public static int zzd(int i4, List<?> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return zzaii.zza(i4, 0L) * size;
    }

    public static int zze(int i4, List<Integer> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzaii.zzg(i4) * size) + zze(list);
    }

    public static int zzf(int i4, List<Long> list, boolean z4) {
        if (list.size() == 0) {
            return 0;
        }
        return (zzaii.zzg(i4) * list.size()) + zzf(list);
    }

    public static int zzg(int i4, List<Integer> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzaii.zzg(i4) * size) + zzg(list);
    }

    public static int zzh(int i4, List<Long> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzaii.zzg(i4) * size) + zzh(list);
    }

    public static int zzi(int i4, List<Integer> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzaii.zzg(i4) * size) + zzi(list);
    }

    public static int zzj(int i4, List<Long> list, boolean z4) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (zzaii.zzg(i4) * size) + zzj(list);
    }

    public static void zzk(int i4, List<Integer> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzk(i4, list, z4);
    }

    public static void zzl(int i4, List<Long> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzl(i4, list, z4);
    }

    public static void zzm(int i4, List<Integer> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzm(i4, list, z4);
    }

    public static void zzn(int i4, List<Long> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzn(i4, list, z4);
    }

    public static int zza(List<?> list) {
        return list.size();
    }

    public static int zzc(List<?> list) {
        return list.size() << 2;
    }

    public static int zzd(List<?> list) {
        return list.size() << 3;
    }

    public static int zza(int i4, List<zzahm> list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iZzg = zzaii.zzg(i4) * size;
        for (int i5 = 0; i5 < list.size(); i5++) {
            iZzg += zzaii.zza(list.get(i5));
        }
        return iZzg;
    }

    public static int zzb(List<Integer> list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzajd)) {
            int iZza = 0;
            while (i4 < size) {
                iZza += zzaii.zza(list.get(i4).intValue());
                i4++;
            }
            return iZza;
        }
        zzajd zzajdVar = (zzajd) list;
        int iZza2 = 0;
        while (i4 < size) {
            iZza2 += zzaii.zza(zzajdVar.zzb(i4));
            i4++;
        }
        return iZza2;
    }

    private static zzamb<?, ?> zzc() {
        try {
            Class<?> clsZze = zze();
            if (clsZze == null) {
                return null;
            }
            return (zzamb) clsZze.getConstructor(new Class[0]).newInstance(new Object[0]);
        } catch (Throwable unused) {
            return null;
        }
    }

    private static Class<?> zzd() {
        try {
            return Class.forName("com.google.protobuf.GeneratedMessage");
        } catch (Throwable unused) {
            return null;
        }
    }

    public static int zze(List<Integer> list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzajd)) {
            int iZzc = 0;
            while (i4 < size) {
                iZzc += zzaii.zzc(list.get(i4).intValue());
                i4++;
            }
            return iZzc;
        }
        zzajd zzajdVar = (zzajd) list;
        int iZzc2 = 0;
        while (i4 < size) {
            iZzc2 += zzaii.zzc(zzajdVar.zzb(i4));
            i4++;
        }
        return iZzc2;
    }

    public static int zzf(List<Long> list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzajz)) {
            int iZzb = 0;
            while (i4 < size) {
                iZzb += zzaii.zzb(list.get(i4).longValue());
                i4++;
            }
            return iZzb;
        }
        zzajz zzajzVar = (zzajz) list;
        int iZzb2 = 0;
        while (i4 < size) {
            iZzb2 += zzaii.zzb(zzajzVar.zzb(i4));
            i4++;
        }
        return iZzb2;
    }

    public static int zzg(List<Integer> list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzajd)) {
            int iZzf = 0;
            while (i4 < size) {
                iZzf += zzaii.zzf(list.get(i4).intValue());
                i4++;
            }
            return iZzf;
        }
        zzajd zzajdVar = (zzajd) list;
        int iZzf2 = 0;
        while (i4 < size) {
            iZzf2 += zzaii.zzf(zzajdVar.zzb(i4));
            i4++;
        }
        return iZzf2;
    }

    public static int zzh(List<Long> list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzajz)) {
            int iZzd = 0;
            while (i4 < size) {
                iZzd += zzaii.zzd(list.get(i4).longValue());
                i4++;
            }
            return iZzd;
        }
        zzajz zzajzVar = (zzajz) list;
        int iZzd2 = 0;
        while (i4 < size) {
            iZzd2 += zzaii.zzd(zzajzVar.zzb(i4));
            i4++;
        }
        return iZzd2;
    }

    public static int zzi(List<Integer> list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzajd)) {
            int iZzh = 0;
            while (i4 < size) {
                iZzh += zzaii.zzh(list.get(i4).intValue());
                i4++;
            }
            return iZzh;
        }
        zzajd zzajdVar = (zzajd) list;
        int iZzh2 = 0;
        while (i4 < size) {
            iZzh2 += zzaii.zzh(zzajdVar.zzb(i4));
            i4++;
        }
        return iZzh2;
    }

    public static int zzj(List<Long> list) {
        int size = list.size();
        int i4 = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzajz)) {
            int iZze = 0;
            while (i4 < size) {
                iZze += zzaii.zze(list.get(i4).longValue());
                i4++;
            }
            return iZze;
        }
        zzajz zzajzVar = (zzajz) list;
        int iZze2 = 0;
        while (i4 < size) {
            iZze2 += zzaii.zze(zzajzVar.zzb(i4));
            i4++;
        }
        return iZze2;
    }

    public static void zzd(int i4, List<Integer> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzd(i4, list, z4);
    }

    public static void zzc(int i4, List<Integer> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzc(i4, list, z4);
    }

    public static int zza(int i4, List<zzakk> list, zzalc zzalcVar) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iZza = 0;
        for (int i5 = 0; i5 < size; i5++) {
            iZza += zzaii.zza(i4, list.get(i5), zzalcVar);
        }
        return iZza;
    }

    public static int zzb(int i4, List<?> list, zzalc zzalcVar) {
        int iZza;
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iZzg = zzaii.zzg(i4) * size;
        for (int i5 = 0; i5 < size; i5++) {
            Object obj = list.get(i5);
            if (obj instanceof zzajo) {
                iZza = zzaii.zza((zzajo) obj);
            } else {
                iZza = zzaii.zza((zzakk) obj, zzalcVar);
            }
            iZzg = iZza + iZzg;
        }
        return iZzg;
    }

    private static Class<?> zze() {
        try {
            return Class.forName("com.google.protobuf.UnknownFieldSetSchema");
        } catch (Throwable unused) {
            return null;
        }
    }

    public static void zzf(int i4, List<Float> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzf(i4, list, z4);
    }

    public static void zzg(int i4, List<Integer> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzg(i4, list, z4);
    }

    public static void zzh(int i4, List<Long> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzh(i4, list, z4);
    }

    public static void zzi(int i4, List<Integer> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzi(i4, list, z4);
    }

    public static void zzj(int i4, List<Long> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzj(i4, list, z4);
    }

    public static int zza(int i4, Object obj, zzalc zzalcVar) {
        if (obj instanceof zzajo) {
            return zzaii.zzb(i4, (zzajo) obj);
        }
        return zzaii.zzb(i4, (zzakk) obj, zzalcVar);
    }

    public static void zze(int i4, List<Long> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zze(i4, list, z4);
    }

    public static zzamb<?, ?> zza() {
        return zzb;
    }

    public static <UT, UB> UB zza(Object obj, int i4, List<Integer> list, zzajh zzajhVar, UB ub, zzamb<UT, UB> zzambVar) {
        if (zzajhVar == null) {
            return ub;
        }
        if (list instanceof RandomAccess) {
            int size = list.size();
            int i5 = 0;
            for (int i6 = 0; i6 < size; i6++) {
                Integer num = list.get(i6);
                int iIntValue = num.intValue();
                if (zzajhVar.zza(iIntValue)) {
                    if (i6 != i5) {
                        list.set(i5, num);
                    }
                    i5++;
                } else {
                    ub = (UB) zza(obj, i4, iIntValue, ub, zzambVar);
                }
            }
            if (i5 != size) {
                list.subList(i5, size).clear();
            }
            return ub;
        }
        Iterator<Integer> it = list.iterator();
        while (it.hasNext()) {
            int iIntValue2 = it.next().intValue();
            if (!zzajhVar.zza(iIntValue2)) {
                ub = (UB) zza(obj, i4, iIntValue2, ub, zzambVar);
                it.remove();
            }
        }
        return ub;
    }

    public static int zzb(int i4, List<?> list) {
        int iZza;
        int iZza2;
        int size = list.size();
        int i5 = 0;
        if (size == 0) {
            return 0;
        }
        int iZzg = zzaii.zzg(i4) * size;
        if (!(list instanceof zzajq)) {
            while (i5 < size) {
                Object obj = list.get(i5);
                if (obj instanceof zzahm) {
                    iZza = zzaii.zza((zzahm) obj);
                } else {
                    iZza = zzaii.zza((String) obj);
                }
                iZzg = iZza + iZzg;
                i5++;
            }
            return iZzg;
        }
        zzajq zzajqVar = (zzajq) list;
        while (i5 < size) {
            Object objZzb = zzajqVar.zzb(i5);
            if (objZzb instanceof zzahm) {
                iZza2 = zzaii.zza((zzahm) objZzb);
            } else {
                iZza2 = zzaii.zza((String) objZzb);
            }
            iZzg = iZza2 + iZzg;
            i5++;
        }
        return iZzg;
    }

    public static <UT, UB> UB zza(Object obj, int i4, int i5, UB ub, zzamb<UT, UB> zzambVar) {
        if (ub == null) {
            ub = zzambVar.zzc(obj);
        }
        zzambVar.zzb(ub, i4, i5);
        return ub;
    }

    public static zzamb<?, ?> zzb() {
        return zzc;
    }

    public static <T, FT extends zzaiu<FT>> void zza(zzair<FT> zzairVar, T t4, T t5) {
        zzais<T> zzaisVarZza = zzairVar.zza(t5);
        if (zzaisVarZza.zza.isEmpty()) {
            return;
        }
        zzairVar.zzb(t4).zza((zzais) zzaisVarZza);
    }

    public static void zzb(int i4, List<Double> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzb(i4, list, z4);
    }

    public static void zzb(int i4, List<?> list, zzanb zzanbVar, zzalc zzalcVar) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzb(i4, list, zzalcVar);
    }

    public static <T> void zza(zzakh zzakhVar, T t4, T t5, long j4) {
        zzamh.zza(t4, j4, zzakhVar.zza(zzamh.zze(t4, j4), zzamh.zze(t5, j4)));
    }

    public static void zzb(int i4, List<String> list, zzanb zzanbVar) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zzb(i4, list);
    }

    public static <T, UT, UB> void zza(zzamb<UT, UB> zzambVar, T t4, T t5) {
        zzambVar.zzc(t4, zzambVar.zza(zzambVar.zzd(t4), zzambVar.zzd(t5)));
    }

    public static void zza(Class<?> cls) {
        Class<?> cls2;
        if (!zzaja.class.isAssignableFrom(cls) && (cls2 = zza) != null && !cls2.isAssignableFrom(cls)) {
            throw new IllegalArgumentException("Message classes must extend GeneratedMessage or GeneratedMessageLite");
        }
    }

    public static void zza(int i4, List<Boolean> list, zzanb zzanbVar, boolean z4) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zza(i4, list, z4);
    }

    public static void zza(int i4, List<zzahm> list, zzanb zzanbVar) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zza(i4, list);
    }

    public static void zza(int i4, List<?> list, zzanb zzanbVar, zzalc zzalcVar) {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzanbVar.zza(i4, list, zzalcVar);
    }

    public static boolean zza(Object obj, Object obj2) {
        if (obj != obj2) {
            return obj != null && obj.equals(obj2);
        }
        return true;
    }
}
