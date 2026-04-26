package com.google.android.gms.internal.p002firebaseauthapi;

import K.k;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.p002firebaseauthapi.zzaiu;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
final class zzais<T extends zzaiu<T>> {
    private static final zzais zzb = new zzais(true);
    final zzalh<T, Object> zza;
    private boolean zzc;
    private boolean zzd;

    private zzais() {
        this.zza = zzalh.zza(16);
    }

    public static int zza(zzamo zzamoVar, int i4, Object obj) {
        int iZzg = zzaii.zzg(i4);
        if (zzamoVar == zzamo.zzj) {
            zzajc.zza((zzakk) obj);
            iZzg <<= 1;
        }
        return iZzg + zza(zzamoVar, obj);
    }

    public static <T extends zzaiu<T>> zzais<T> zzb() {
        return zzb;
    }

    /* JADX WARN: Multi-variable type inference failed */
    public final /* synthetic */ Object clone() {
        zzais zzaisVar = new zzais();
        for (int i4 = 0; i4 < this.zza.zzb(); i4++) {
            Map.Entry<K, Object> entryZzb = this.zza.zzb(i4);
            zzaisVar.zzb((zzaiu) entryZzb.getKey(), entryZzb.getValue());
        }
        Iterator it = this.zza.zzc().iterator();
        while (it.hasNext()) {
            Map.Entry entry = (Map.Entry) it.next();
            zzaisVar.zzb((zzaiu) entry.getKey(), entry.getValue());
        }
        zzaisVar.zzd = this.zzd;
        return zzaisVar;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof zzais) {
            return this.zza.equals(((zzais) obj).zza);
        }
        return false;
    }

    public final int hashCode() {
        return this.zza.hashCode();
    }

    public final Iterator<Map.Entry<T, Object>> zzc() {
        return this.zzd ? new zzajp(this.zza.zzd().iterator()) : this.zza.zzd().iterator();
    }

    public final Iterator<Map.Entry<T, Object>> zzd() {
        return this.zzd ? new zzajp(this.zza.entrySet().iterator()) : this.zza.entrySet().iterator();
    }

    public final void zze() {
        if (this.zzc) {
            return;
        }
        for (int i4 = 0; i4 < this.zza.zzb(); i4++) {
            Map.Entry<K, Object> entryZzb = this.zza.zzb(i4);
            if (entryZzb.getValue() instanceof zzaja) {
                ((zzaja) entryZzb.getValue()).zzs();
            }
        }
        this.zza.zza();
        this.zzc = true;
    }

    public final boolean zzf() {
        return this.zzc;
    }

    public final boolean zzg() {
        for (int i4 = 0; i4 < this.zza.zzb(); i4++) {
            if (!zzc(this.zza.zzb(i4))) {
                return false;
            }
        }
        Iterator it = this.zza.zzc().iterator();
        while (it.hasNext()) {
            if (!zzc((Map.Entry) it.next())) {
                return false;
            }
        }
        return true;
    }

    private final void zzb(Map.Entry<T, Object> entry) {
        T key = entry.getKey();
        Object value = entry.getValue();
        boolean z4 = value instanceof zzajk;
        if (key.zze()) {
            if (z4) {
                throw new IllegalStateException("Lazy fields can not be repeated");
            }
            Object objZza = zza((zzaiu) key);
            if (objZza == null) {
                objZza = new ArrayList();
            }
            Iterator it = ((List) value).iterator();
            while (it.hasNext()) {
                ((List) objZza).add(zza(it.next()));
            }
            this.zza.put(key, objZza);
            return;
        }
        if (key.zzc() != zzamy.MESSAGE) {
            if (z4) {
                throw new IllegalStateException("Lazy fields must be message-valued");
            }
            this.zza.put(key, zza(value));
            return;
        }
        Object objZza2 = zza((zzaiu) key);
        if (objZza2 != null) {
            if (z4) {
                value = zzajk.zza();
            }
            this.zza.put(key, objZza2 instanceof zzakt ? key.zza((zzakt) objZza2, (zzakt) value) : key.zza(((zzakk) objZza2).zzq(), (zzakk) value).zzf());
        } else {
            this.zza.put(key, zza(value));
            if (z4) {
                this.zzd = true;
            }
        }
    }

    private zzais(zzalh<T, Object> zzalhVar) {
        this.zza = zzalhVar;
        zze();
    }

    private static void zzc(T t4, Object obj) {
        zzamo zzamoVarZzb = t4.zzb();
        zzajc.zza(obj);
        boolean z4 = true;
        switch (zzaiv.zza[zzamoVarZzb.zzb().ordinal()]) {
            case 1:
                z4 = obj instanceof Integer;
                break;
            case 2:
                z4 = obj instanceof Long;
                break;
            case 3:
                z4 = obj instanceof Float;
                break;
            case 4:
                z4 = obj instanceof Double;
                break;
            case 5:
                z4 = obj instanceof Boolean;
                break;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                z4 = obj instanceof String;
                break;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                if (!(obj instanceof zzahm) && !(obj instanceof byte[])) {
                    z4 = false;
                }
                break;
            case k.BYTES_FIELD_NUMBER /* 8 */:
                if (!(obj instanceof Integer) && !(obj instanceof zzajf)) {
                    z4 = false;
                }
                break;
            case 9:
                if (!(obj instanceof zzakk) && !(obj instanceof zzajk)) {
                    z4 = false;
                }
                break;
            default:
                z4 = false;
                break;
        }
        if (!z4) {
            throw new IllegalArgumentException(String.format("Wrong object type used with protocol message reflection.\nField number: %d, field java type: %s, value type: %s\n", Integer.valueOf(t4.zza()), t4.zzb().zzb(), obj.getClass().getName()));
        }
    }

    private static int zza(zzamo zzamoVar, Object obj) {
        switch (zzaiv.zzb[zzamoVar.ordinal()]) {
            case 1:
                return zzaii.zza(((Double) obj).doubleValue());
            case 2:
                return zzaii.zza(((Float) obj).floatValue());
            case 3:
                return zzaii.zzb(((Long) obj).longValue());
            case 4:
                return zzaii.zze(((Long) obj).longValue());
            case 5:
                return zzaii.zzc(((Integer) obj).intValue());
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return zzaii.zza(((Long) obj).longValue());
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return zzaii.zzb(((Integer) obj).intValue());
            case k.BYTES_FIELD_NUMBER /* 8 */:
                return zzaii.zza(((Boolean) obj).booleanValue());
            case 9:
                return zzaii.zza((zzakk) obj);
            case 10:
                if (obj instanceof zzajk) {
                    return zzaii.zza((zzajk) obj);
                }
                return zzaii.zzb((zzakk) obj);
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                if (obj instanceof zzahm) {
                    return zzaii.zza((zzahm) obj);
                }
                return zzaii.zza((String) obj);
            case 12:
                if (obj instanceof zzahm) {
                    return zzaii.zza((zzahm) obj);
                }
                return zzaii.zza((byte[]) obj);
            case 13:
                return zzaii.zzh(((Integer) obj).intValue());
            case 14:
                return zzaii.zze(((Integer) obj).intValue());
            case 15:
                return zzaii.zzc(((Long) obj).longValue());
            case 16:
                return zzaii.zzf(((Integer) obj).intValue());
            case 17:
                return zzaii.zzd(((Long) obj).longValue());
            case 18:
                if (obj instanceof zzajf) {
                    return zzaii.zza(((zzajf) obj).zza());
                }
                return zzaii.zza(((Integer) obj).intValue());
            default:
                throw new RuntimeException("There is no way to get here, but the compiler thinks otherwise.");
        }
    }

    private zzais(boolean z4) {
        this(zzalh.zza(0));
        zze();
    }

    private static <T extends zzaiu<T>> boolean zzc(Map.Entry<T, Object> entry) {
        T key = entry.getKey();
        if (key.zzc() != zzamy.MESSAGE) {
            return true;
        }
        if (key.zze()) {
            Iterator it = ((List) entry.getValue()).iterator();
            while (it.hasNext()) {
                if (!zzb(it.next())) {
                    return false;
                }
            }
            return true;
        }
        return zzb(entry.getValue());
    }

    private final void zzb(T t4, Object obj) {
        if (t4.zze()) {
            if (obj instanceof List) {
                ArrayList arrayList = new ArrayList();
                arrayList.addAll((List) obj);
                int size = arrayList.size();
                int i4 = 0;
                while (i4 < size) {
                    Object obj2 = arrayList.get(i4);
                    i4++;
                    zzc(t4, obj2);
                }
                obj = arrayList;
            } else {
                throw new IllegalArgumentException("Wrong object type used with protocol message reflection.");
            }
        } else {
            zzc(t4, obj);
        }
        if (obj instanceof zzajk) {
            this.zzd = true;
        }
        this.zza.put(t4, obj);
    }

    public static int zza(zzaiu<?> zzaiuVar, Object obj) {
        zzamo zzamoVarZzb = zzaiuVar.zzb();
        int iZza = zzaiuVar.zza();
        if (zzaiuVar.zze()) {
            List list = (List) obj;
            int iZza2 = 0;
            if (zzaiuVar.zzd()) {
                if (list.isEmpty()) {
                    return 0;
                }
                Iterator it = list.iterator();
                while (it.hasNext()) {
                    iZza2 += zza(zzamoVarZzb, it.next());
                }
                return zzaii.zzh(iZza2) + zzaii.zzg(iZza) + iZza2;
            }
            Iterator it2 = list.iterator();
            while (it2.hasNext()) {
                iZza2 += zza(zzamoVarZzb, iZza, it2.next());
            }
            return iZza2;
        }
        return zza(zzamoVarZzb, iZza, obj);
    }

    private static boolean zzb(Object obj) {
        if (obj instanceof zzakm) {
            return ((zzakm) obj).zzu();
        }
        if (obj instanceof zzajk) {
            return true;
        }
        throw new IllegalArgumentException("Wrong object type used with protocol message reflection.");
    }

    public final int zza() {
        int iZza = 0;
        for (int i4 = 0; i4 < this.zza.zzb(); i4++) {
            iZza += zza((Map.Entry) this.zza.zzb(i4));
        }
        Iterator it = this.zza.zzc().iterator();
        while (it.hasNext()) {
            iZza += zza((Map.Entry) it.next());
        }
        return iZza;
    }

    private static int zza(Map.Entry<T, Object> entry) {
        T key = entry.getKey();
        Object value = entry.getValue();
        if (key.zzc() == zzamy.MESSAGE && !key.zze() && !key.zzd()) {
            if (value instanceof zzajk) {
                return zzaii.zza(entry.getKey().zza(), (zzajk) value);
            }
            return zzaii.zza(entry.getKey().zza(), (zzakk) value);
        }
        return zza((zzaiu<?>) key, value);
    }

    private static Object zza(Object obj) {
        if (obj instanceof zzakt) {
            return ((zzakt) obj).clone();
        }
        if (!(obj instanceof byte[])) {
            return obj;
        }
        byte[] bArr = (byte[]) obj;
        byte[] bArr2 = new byte[bArr.length];
        System.arraycopy(bArr, 0, bArr2, 0, bArr.length);
        return bArr2;
    }

    private final Object zza(T t4) {
        Object obj = this.zza.get(t4);
        return obj instanceof zzajk ? zzajk.zza() : obj;
    }

    public final void zza(zzais<T> zzaisVar) {
        for (int i4 = 0; i4 < zzaisVar.zza.zzb(); i4++) {
            zzb((Map.Entry) zzaisVar.zza.zzb(i4));
        }
        Iterator it = zzaisVar.zza.zzc().iterator();
        while (it.hasNext()) {
            zzb((Map.Entry) it.next());
        }
    }

    public static void zza(zzaii zzaiiVar, zzamo zzamoVar, int i4, Object obj) {
        if (zzamoVar == zzamo.zzj) {
            zzakk zzakkVar = (zzakk) obj;
            zzajc.zza(zzakkVar);
            zzaiiVar.zzj(i4, 3);
            zzakkVar.zza(zzaiiVar);
            zzaiiVar.zzj(i4, 4);
        }
        zzaiiVar.zzj(i4, zzamoVar.zza());
        switch (zzaiv.zzb[zzamoVar.ordinal()]) {
            case 1:
                zzaiiVar.zzb(((Double) obj).doubleValue());
                break;
            case 2:
                zzaiiVar.zzb(((Float) obj).floatValue());
                break;
            case 3:
                zzaiiVar.zzh(((Long) obj).longValue());
                break;
            case 4:
                zzaiiVar.zzh(((Long) obj).longValue());
                break;
            case 5:
                zzaiiVar.zzj(((Integer) obj).intValue());
                break;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                zzaiiVar.zzf(((Long) obj).longValue());
                break;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                zzaiiVar.zzi(((Integer) obj).intValue());
                break;
            case k.BYTES_FIELD_NUMBER /* 8 */:
                zzaiiVar.zzb(((Boolean) obj).booleanValue());
                break;
            case 9:
                ((zzakk) obj).zza(zzaiiVar);
                break;
            case 10:
                zzaiiVar.zzc((zzakk) obj);
                break;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                if (obj instanceof zzahm) {
                    zzaiiVar.zzb((zzahm) obj);
                } else {
                    zzaiiVar.zzb((String) obj);
                }
                break;
            case 12:
                if (obj instanceof zzahm) {
                    zzaiiVar.zzb((zzahm) obj);
                } else {
                    byte[] bArr = (byte[]) obj;
                    zzaiiVar.zzb(bArr, 0, bArr.length);
                }
                break;
            case 13:
                zzaiiVar.zzl(((Integer) obj).intValue());
                break;
            case 14:
                zzaiiVar.zzi(((Integer) obj).intValue());
                break;
            case 15:
                zzaiiVar.zzf(((Long) obj).longValue());
                break;
            case 16:
                zzaiiVar.zzk(((Integer) obj).intValue());
                break;
            case 17:
                zzaiiVar.zzg(((Long) obj).longValue());
                break;
            case 18:
                if (obj instanceof zzajf) {
                    zzaiiVar.zzj(((zzajf) obj).zza());
                } else {
                    zzaiiVar.zzj(((Integer) obj).intValue());
                }
                break;
        }
    }
}
