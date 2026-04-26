package com.google.android.recaptcha.internal;

import J3.i;
import e1.k;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import x3.AbstractC0726f;
import x3.AbstractC0730j;
import x3.p;

/* JADX INFO: loaded from: classes.dex */
public final class zzde implements zzdd {
    public static final zzde zza = new zzde();

    private zzde() {
    }

    private static final List zzc(Object obj) {
        if (obj instanceof byte[]) {
            return AbstractC0726f.l0((byte[]) obj);
        }
        boolean z4 = obj instanceof short[];
        p pVar = p.f6784a;
        int i4 = 0;
        if (z4) {
            short[] sArr = (short[]) obj;
            i.e(sArr, "<this>");
            int length = sArr.length;
            if (length == 0) {
                return pVar;
            }
            if (length == 1) {
                return k.x(Short.valueOf(sArr[0]));
            }
            ArrayList arrayList = new ArrayList(sArr.length);
            int length2 = sArr.length;
            while (i4 < length2) {
                arrayList.add(Short.valueOf(sArr[i4]));
                i4++;
            }
            return arrayList;
        }
        if (obj instanceof int[]) {
            int[] iArr = (int[]) obj;
            i.e(iArr, "<this>");
            int length3 = iArr.length;
            if (length3 == 0) {
                return pVar;
            }
            if (length3 == 1) {
                return k.x(Integer.valueOf(iArr[0]));
            }
            ArrayList arrayList2 = new ArrayList(iArr.length);
            int length4 = iArr.length;
            while (i4 < length4) {
                arrayList2.add(Integer.valueOf(iArr[i4]));
                i4++;
            }
            return arrayList2;
        }
        if (obj instanceof long[]) {
            return AbstractC0726f.m0((long[]) obj);
        }
        if (obj instanceof float[]) {
            float[] fArr = (float[]) obj;
            i.e(fArr, "<this>");
            int length5 = fArr.length;
            if (length5 == 0) {
                return pVar;
            }
            if (length5 == 1) {
                return k.x(Float.valueOf(fArr[0]));
            }
            ArrayList arrayList3 = new ArrayList(fArr.length);
            int length6 = fArr.length;
            while (i4 < length6) {
                arrayList3.add(Float.valueOf(fArr[i4]));
                i4++;
            }
            return arrayList3;
        }
        if (!(obj instanceof double[])) {
            return null;
        }
        double[] dArr = (double[]) obj;
        i.e(dArr, "<this>");
        int length7 = dArr.length;
        if (length7 == 0) {
            return pVar;
        }
        if (length7 == 1) {
            return k.x(Double.valueOf(dArr[0]));
        }
        ArrayList arrayList4 = new ArrayList(dArr.length);
        int length8 = dArr.length;
        while (i4 < length8) {
            arrayList4.add(Double.valueOf(dArr[i4]));
            i4++;
        }
        return arrayList4;
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
        if (true != Objects.nonNull(objZza2)) {
            objZza2 = null;
        }
        if (objZza2 == null) {
            throw new zzae(4, 5, null);
        }
        zzcjVar.zzc().zzf(i4, zzb(objZza, objZza2));
    }

    public final Object zzb(Object obj, Object obj2) throws zzae {
        List listZzc = zzc(obj);
        List listZzc2 = zzc(obj2);
        if (obj instanceof Number) {
            if (obj2 instanceof Number) {
                return Double.valueOf(Math.pow(((Number) obj).doubleValue(), ((Number) obj2).doubleValue()));
            }
            if (listZzc2 != null) {
                ArrayList arrayList = new ArrayList(AbstractC0730j.V(listZzc2));
                Iterator it = listZzc2.iterator();
                while (it.hasNext()) {
                    arrayList.add(Double.valueOf(Math.pow(((Number) it.next()).doubleValue(), ((Number) obj).doubleValue())));
                }
                return arrayList.toArray(new Double[0]);
            }
        }
        if (listZzc != null && (obj2 instanceof Number)) {
            ArrayList arrayList2 = new ArrayList(AbstractC0730j.V(listZzc));
            Iterator it2 = listZzc.iterator();
            while (it2.hasNext()) {
                arrayList2.add(Double.valueOf(Math.pow(((Number) it2.next()).doubleValue(), ((Number) obj2).doubleValue())));
            }
            return arrayList2.toArray(new Double[0]);
        }
        if (listZzc == null || listZzc2 == null) {
            throw new zzae(4, 5, null);
        }
        zzdc.zza(this, listZzc.size(), listZzc2.size());
        int size = listZzc.size();
        Double[] dArr = new Double[size];
        for (int i4 = 0; i4 < size; i4++) {
            dArr[i4] = Double.valueOf(Math.pow(((Number) listZzc.get(i4)).doubleValue(), ((Number) listZzc2.get(i4)).doubleValue()));
        }
        return dArr;
    }
}
