package com.google.android.recaptcha.internal;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
final class zzjo extends zzjs {
    private static final Class zza = Collections.unmodifiableList(Collections.EMPTY_LIST).getClass();

    public /* synthetic */ zzjo(zzjn zzjnVar) {
        super(null);
    }

    private static List zzf(Object obj, long j4, int i4) {
        List list = (List) zzlv.zzf(obj, j4);
        if (list.isEmpty()) {
            List zzjlVar = list instanceof zzjm ? new zzjl(i4) : ((list instanceof zzkm) && (list instanceof zzjb)) ? ((zzjb) list).zzd(i4) : new ArrayList(i4);
            zzlv.zzs(obj, j4, zzjlVar);
            return zzjlVar;
        }
        if (zza.isAssignableFrom(list.getClass())) {
            ArrayList arrayList = new ArrayList(list.size() + i4);
            arrayList.addAll(list);
            zzlv.zzs(obj, j4, arrayList);
            return arrayList;
        }
        if (list instanceof zzlq) {
            zzjl zzjlVar2 = new zzjl(list.size() + i4);
            zzjlVar2.addAll(zzjlVar2.size(), (zzlq) list);
            zzlv.zzs(obj, j4, zzjlVar2);
            return zzjlVar2;
        }
        if ((list instanceof zzkm) && (list instanceof zzjb)) {
            zzjb zzjbVar = (zzjb) list;
            if (!zzjbVar.zzc()) {
                zzjb zzjbVarZzd = zzjbVar.zzd(list.size() + i4);
                zzlv.zzs(obj, j4, zzjbVarZzd);
                return zzjbVarZzd;
            }
        }
        return list;
    }

    @Override // com.google.android.recaptcha.internal.zzjs
    public final List zza(Object obj, long j4) {
        return zzf(obj, j4, 10);
    }

    @Override // com.google.android.recaptcha.internal.zzjs
    public final void zzb(Object obj, long j4) {
        Object objUnmodifiableList;
        List list = (List) zzlv.zzf(obj, j4);
        if (list instanceof zzjm) {
            objUnmodifiableList = ((zzjm) list).zze();
        } else {
            if (zza.isAssignableFrom(list.getClass())) {
                return;
            }
            if ((list instanceof zzkm) && (list instanceof zzjb)) {
                zzjb zzjbVar = (zzjb) list;
                if (zzjbVar.zzc()) {
                    zzjbVar.zzb();
                    return;
                }
                return;
            }
            objUnmodifiableList = Collections.unmodifiableList(list);
        }
        zzlv.zzs(obj, j4, objUnmodifiableList);
    }

    @Override // com.google.android.recaptcha.internal.zzjs
    public final void zzc(Object obj, Object obj2, long j4) {
        List list = (List) zzlv.zzf(obj2, j4);
        List listZzf = zzf(obj, j4, list.size());
        int size = listZzf.size();
        int size2 = list.size();
        if (size > 0 && size2 > 0) {
            listZzf.addAll(list);
        }
        if (size > 0) {
            list = listZzf;
        }
        zzlv.zzs(obj, j4, list);
    }

    private zzjo() {
        super(null);
    }
}
