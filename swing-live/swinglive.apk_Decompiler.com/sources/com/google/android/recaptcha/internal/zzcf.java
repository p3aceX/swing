package com.google.android.recaptcha.internal;

import I3.p;
import J3.i;
import java.lang.reflect.Method;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class zzcf extends zzce {
    private final p zza;
    private final String zzb;

    public zzcf(p pVar, String str, Object obj) {
        super(obj);
        this.zza = pVar;
        this.zzb = str;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r0v0, types: [x3.p] */
    /* JADX WARN: Type inference failed for: r0v1, types: [java.lang.Iterable] */
    /* JADX WARN: Type inference failed for: r0v3, types: [java.util.ArrayList] */
    /* JADX WARN: Type inference failed for: r5v3, types: [com.google.android.recaptcha.internal.zzin, com.google.android.recaptcha.internal.zzpi] */
    @Override // com.google.android.recaptcha.internal.zzce
    public final boolean zza(Object obj, Method method, Object[] objArr) {
        ?? arrayList;
        if (!i.a(method.getName(), this.zzb)) {
            return false;
        }
        ?? Zzf = zzpl.zzf();
        if (objArr != null) {
            arrayList = new ArrayList(objArr.length);
            for (Object obj2 : objArr) {
                zzpj zzpjVarZzf = zzpk.zzf();
                zzpjVarZzf.zzv(obj2.toString());
                arrayList.add((zzpk) zzpjVarZzf.zzj());
            }
        } else {
            arrayList = x3.p.f6784a;
        }
        Zzf.zzd(arrayList);
        zzpl zzplVar = (zzpl) Zzf.zzj();
        p pVar = this.zza;
        byte[] bArrZzd = zzplVar.zzd();
        pVar.invoke(objArr, zzfy.zzh().zzi(bArrZzd, 0, bArrZzd.length));
        return true;
    }
}
