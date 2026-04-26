package com.google.android.recaptcha.internal;

import J3.i;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.List;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class zzch extends zzce {
    private final zzcg zza;
    private final String zzb;

    public zzch(zzcg zzcgVar, String str, Object obj) {
        super(obj);
        this.zza = zzcgVar;
        this.zzb = str;
    }

    @Override // com.google.android.recaptcha.internal.zzce
    public final boolean zza(Object obj, Method method, Object[] objArr) {
        List listAsList;
        if (!i.a(method.getName(), this.zzb)) {
            return false;
        }
        zzcg zzcgVar = this.zza;
        if (objArr != null) {
            listAsList = Arrays.asList(objArr);
            i.d(listAsList, "asList(...)");
        } else {
            listAsList = p.f6784a;
        }
        zzcgVar.zzb(listAsList);
        return true;
    }
}
