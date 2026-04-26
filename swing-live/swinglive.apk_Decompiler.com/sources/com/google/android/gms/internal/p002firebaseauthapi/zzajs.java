package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzajs extends zzajt {
    private static final Class<?> zza = Collections.unmodifiableList(Collections.EMPTY_LIST).getClass();

    private static <E> List<E> zzc(Object obj, long j4) {
        return (List) zzamh.zze(obj, j4);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajt
    public final <L> List<L> zza(Object obj, long j4) {
        return zza(obj, j4, 10);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajt
    public final void zzb(Object obj, long j4) {
        Object objUnmodifiableList;
        List list = (List) zzamh.zze(obj, j4);
        if (list instanceof zzajq) {
            objUnmodifiableList = ((zzajq) list).a_();
        } else {
            if (zza.isAssignableFrom(list.getClass())) {
                return;
            }
            if ((list instanceof zzakw) && (list instanceof zzajg)) {
                zzajg zzajgVar = (zzajg) list;
                if (zzajgVar.zzc()) {
                    zzajgVar.b_();
                    return;
                }
                return;
            }
            objUnmodifiableList = Collections.unmodifiableList(list);
        }
        zzamh.zza(obj, j4, objUnmodifiableList);
    }

    private zzajs() {
        super();
    }

    private static <L> List<L> zza(Object obj, long j4, int i4) {
        List<L> listZzc = zzc(obj, j4);
        if (listZzc.isEmpty()) {
            List<L> zzajrVar = listZzc instanceof zzajq ? new zzajr(i4) : ((listZzc instanceof zzakw) && (listZzc instanceof zzajg)) ? ((zzajg) listZzc).zza(i4) : new ArrayList<>(i4);
            zzamh.zza(obj, j4, zzajrVar);
            return zzajrVar;
        }
        if (zza.isAssignableFrom(listZzc.getClass())) {
            ArrayList arrayList = new ArrayList(listZzc.size() + i4);
            arrayList.addAll(listZzc);
            zzamh.zza(obj, j4, arrayList);
            return arrayList;
        }
        if (listZzc instanceof zzamg) {
            zzajr zzajrVar2 = new zzajr(listZzc.size() + i4);
            zzajrVar2.addAll((zzamg) listZzc);
            zzamh.zza(obj, j4, zzajrVar2);
            return zzajrVar2;
        }
        if ((listZzc instanceof zzakw) && (listZzc instanceof zzajg)) {
            zzajg zzajgVar = (zzajg) listZzc;
            if (!zzajgVar.zzc()) {
                zzajg zzajgVarZza = zzajgVar.zza(listZzc.size() + i4);
                zzamh.zza(obj, j4, zzajgVarZza);
                return zzajgVarZza;
            }
        }
        return listZzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzajt
    public final <E> void zza(Object obj, Object obj2, long j4) {
        List listZzc = zzc(obj2, j4);
        List listZza = zza(obj, j4, listZzc.size());
        int size = listZza.size();
        int size2 = listZzc.size();
        if (size > 0 && size2 > 0) {
            listZza.addAll(listZzc);
        }
        if (size > 0) {
            listZzc = listZza;
        }
        zzamh.zza(obj, j4, listZzc);
    }
}
