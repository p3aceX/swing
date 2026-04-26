package com.google.android.recaptcha.internal;

import java.lang.reflect.Array;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class zzda implements zzdd {
    public static final zzda zza = new zzda();

    private zzda() {
    }

    @Override // com.google.android.recaptcha.internal.zzdd
    public final void zza(int i4, zzcj zzcjVar, zzpq... zzpqVarArr) throws zzae {
        if (zzpqVarArr.length != 2) {
            throw new zzae(4, 3, null);
        }
        Object objZza = zzcjVar.zzc().zza(zzpqVarArr[0]);
        if (true != Objects.nonNull(objZza)) {
            objZza = null;
        }
        if (objZza == null) {
            throw new zzae(4, 5, null);
        }
        Object objZza2 = zzcjVar.zzc().zza(zzpqVarArr[1]);
        if (true != (objZza2 instanceof Integer)) {
            objZza2 = null;
        }
        Integer num = (Integer) objZza2;
        if (num == null) {
            throw new zzae(4, 5, null);
        }
        int iIntValue = num.intValue();
        try {
            if (objZza instanceof String) {
                objZza = zzcjVar.zzh().zza((String) objZza);
            }
            zzcjVar.zzc().zzf(i4, Array.newInstance((Class<?>) zzci.zza(objZza), iIntValue));
        } catch (Exception e) {
            throw new zzae(6, 21, e);
        }
    }
}
