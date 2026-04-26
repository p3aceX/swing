package com.google.android.recaptcha.internal;

import M3.e;
import M3.f;
import P3.a;
import a.AbstractC0184a;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Objects;
import x3.AbstractC0728h;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public final class zzdn implements zzdd {
    public static final zzdn zza = new zzdn();

    private zzdn() {
    }

    private final Object zzb(Object obj, Object obj2) throws zzae {
        boolean z4 = obj instanceof Byte;
        if (z4 && (obj2 instanceof Byte)) {
            return Integer.valueOf(((Number) obj).intValue() % ((Number) obj2).intValue());
        }
        boolean z5 = obj instanceof Short;
        if (z5 && (obj2 instanceof Short)) {
            return Integer.valueOf(((Number) obj).intValue() % ((Number) obj2).intValue());
        }
        boolean z6 = obj instanceof Integer;
        if (z6 && (obj2 instanceof Integer)) {
            return Integer.valueOf(((Number) obj).intValue() % ((Number) obj2).intValue());
        }
        boolean z7 = obj instanceof Long;
        if (z7 && (obj2 instanceof Long)) {
            return Long.valueOf(((Number) obj).longValue() % ((Number) obj2).longValue());
        }
        boolean z8 = obj instanceof Float;
        if (z8 && (obj2 instanceof Float)) {
            return Float.valueOf(((Number) obj).floatValue() % ((Number) obj2).floatValue());
        }
        boolean z9 = obj instanceof Double;
        if (z9 && (obj2 instanceof Double)) {
            return Double.valueOf(((Number) obj).doubleValue() % ((Number) obj2).doubleValue());
        }
        int i4 = 0;
        if (obj instanceof String) {
            if (obj2 instanceof Byte) {
                byte[] bytes = ((String) obj).getBytes(a.f1492a);
                int length = bytes.length;
                ArrayList arrayList = new ArrayList(length);
                while (i4 < length) {
                    arrayList.add(Byte.valueOf((byte) (bytes[i4] % ((Number) obj2).intValue())));
                    i4++;
                }
                return new String(AbstractC0728h.f0(arrayList), a.f1492a);
            }
            if (obj2 instanceof Integer) {
                char[] charArray = ((String) obj).toCharArray();
                int length2 = charArray.length;
                ArrayList arrayList2 = new ArrayList(length2);
                while (i4 < length2) {
                    arrayList2.add(Integer.valueOf(charArray[i4] % ((Number) obj2).intValue()));
                    i4++;
                }
                return AbstractC0728h.h0(arrayList2);
            }
        }
        if (z4 && (obj2 instanceof byte[])) {
            byte[] bArr = (byte[]) obj2;
            ArrayList arrayList3 = new ArrayList(bArr.length);
            for (byte b5 : bArr) {
                arrayList3.add(Integer.valueOf(b5 % ((Number) obj).intValue()));
            }
            return arrayList3.toArray(new Integer[0]);
        }
        if (z5 && (obj2 instanceof short[])) {
            short[] sArr = (short[]) obj2;
            ArrayList arrayList4 = new ArrayList(sArr.length);
            for (short s4 : sArr) {
                arrayList4.add(Integer.valueOf(s4 % ((Number) obj).intValue()));
            }
            return arrayList4.toArray(new Integer[0]);
        }
        if (z6 && (obj2 instanceof int[])) {
            int[] iArr = (int[]) obj2;
            ArrayList arrayList5 = new ArrayList(iArr.length);
            for (int i5 : iArr) {
                arrayList5.add(Integer.valueOf(i5 % ((Number) obj).intValue()));
            }
            return arrayList5.toArray(new Integer[0]);
        }
        if (z7 && (obj2 instanceof long[])) {
            long[] jArr = (long[]) obj2;
            ArrayList arrayList6 = new ArrayList(jArr.length);
            for (long j4 : jArr) {
                arrayList6.add(Long.valueOf(j4 % ((Number) obj).longValue()));
            }
            return arrayList6.toArray(new Long[0]);
        }
        if (z8 && (obj2 instanceof float[])) {
            float[] fArr = (float[]) obj2;
            ArrayList arrayList7 = new ArrayList(fArr.length);
            for (float f4 : fArr) {
                arrayList7.add(Float.valueOf(f4 % ((Number) obj).floatValue()));
            }
            return arrayList7.toArray(new Float[0]);
        }
        if (z9 && (obj2 instanceof double[])) {
            double[] dArr = (double[]) obj2;
            ArrayList arrayList8 = new ArrayList(dArr.length);
            for (double d5 : dArr) {
                arrayList8.add(Double.valueOf(d5 % ((Number) obj).doubleValue()));
            }
            return arrayList8.toArray(new Double[0]);
        }
        boolean z10 = obj instanceof byte[];
        if (z10 && (obj2 instanceof Byte)) {
            byte[] bArr2 = (byte[]) obj;
            ArrayList arrayList9 = new ArrayList(bArr2.length);
            for (byte b6 : bArr2) {
                arrayList9.add(Integer.valueOf(b6 % ((Number) obj2).intValue()));
            }
            return arrayList9.toArray(new Integer[0]);
        }
        boolean z11 = obj instanceof short[];
        if (z11 && (obj2 instanceof Short)) {
            short[] sArr2 = (short[]) obj;
            ArrayList arrayList10 = new ArrayList(sArr2.length);
            for (short s5 : sArr2) {
                arrayList10.add(Integer.valueOf(s5 % ((Number) obj2).intValue()));
            }
            return arrayList10.toArray(new Integer[0]);
        }
        boolean z12 = obj instanceof int[];
        if (z12 && (obj2 instanceof Integer)) {
            int[] iArr2 = (int[]) obj;
            int length3 = iArr2.length;
            ArrayList arrayList11 = new ArrayList(length3);
            while (i4 < length3) {
                arrayList11.add(Integer.valueOf(iArr2[i4] % ((Number) obj2).intValue()));
                i4++;
            }
            return AbstractC0728h.h0(arrayList11);
        }
        boolean z13 = obj instanceof long[];
        if (z13 && (obj2 instanceof Long)) {
            long[] jArr2 = (long[]) obj;
            ArrayList arrayList12 = new ArrayList(jArr2.length);
            for (long j5 : jArr2) {
                arrayList12.add(Long.valueOf(j5 % ((Number) obj2).longValue()));
            }
            return arrayList12.toArray(new Long[0]);
        }
        boolean z14 = obj instanceof float[];
        if (z14 && (obj2 instanceof Float)) {
            float[] fArr2 = (float[]) obj;
            ArrayList arrayList13 = new ArrayList(fArr2.length);
            for (float f5 : fArr2) {
                arrayList13.add(Float.valueOf(f5 % ((Number) obj2).floatValue()));
            }
            return arrayList13.toArray(new Float[0]);
        }
        boolean z15 = obj instanceof double[];
        if (z15 && (obj2 instanceof Double)) {
            double[] dArr2 = (double[]) obj;
            ArrayList arrayList14 = new ArrayList(dArr2.length);
            for (double d6 : dArr2) {
                arrayList14.add(Double.valueOf(d6 % ((Number) obj2).doubleValue()));
            }
            return arrayList14.toArray(new Double[0]);
        }
        if (z10 && (obj2 instanceof byte[])) {
            byte[] bArr3 = (byte[]) obj;
            int length4 = bArr3.length;
            byte[] bArr4 = (byte[]) obj2;
            zzdc.zza(this, length4, bArr4.length);
            f fVarZ = AbstractC0184a.Z(0, length4);
            ArrayList arrayList15 = new ArrayList(AbstractC0730j.V(fVarZ));
            Iterator it = fVarZ.iterator();
            while (((e) it).f1100c) {
                int iA = ((e) it).a();
                arrayList15.add(Integer.valueOf(bArr3[iA] % bArr4[iA]));
            }
            return arrayList15.toArray(new Integer[0]);
        }
        if (z11 && (obj2 instanceof short[])) {
            short[] sArr3 = (short[]) obj;
            int length5 = sArr3.length;
            short[] sArr4 = (short[]) obj2;
            zzdc.zza(this, length5, sArr4.length);
            f fVarZ2 = AbstractC0184a.Z(0, length5);
            ArrayList arrayList16 = new ArrayList(AbstractC0730j.V(fVarZ2));
            Iterator it2 = fVarZ2.iterator();
            while (((e) it2).f1100c) {
                int iA2 = ((e) it2).a();
                arrayList16.add(Integer.valueOf(sArr3[iA2] % sArr4[iA2]));
            }
            return arrayList16.toArray(new Integer[0]);
        }
        if (z12 && (obj2 instanceof int[])) {
            int[] iArr3 = (int[]) obj;
            int length6 = iArr3.length;
            int[] iArr4 = (int[]) obj2;
            zzdc.zza(this, length6, iArr4.length);
            f fVarZ3 = AbstractC0184a.Z(0, length6);
            ArrayList arrayList17 = new ArrayList(AbstractC0730j.V(fVarZ3));
            Iterator it3 = fVarZ3.iterator();
            while (((e) it3).f1100c) {
                int iA3 = ((e) it3).a();
                arrayList17.add(Integer.valueOf(iArr3[iA3] % iArr4[iA3]));
            }
            return arrayList17.toArray(new Integer[0]);
        }
        if (z13 && (obj2 instanceof long[])) {
            long[] jArr3 = (long[]) obj;
            int length7 = jArr3.length;
            long[] jArr4 = (long[]) obj2;
            zzdc.zza(this, length7, jArr4.length);
            f fVarZ4 = AbstractC0184a.Z(0, length7);
            ArrayList arrayList18 = new ArrayList(AbstractC0730j.V(fVarZ4));
            Iterator it4 = fVarZ4.iterator();
            while (((e) it4).f1100c) {
                int iA4 = ((e) it4).a();
                arrayList18.add(Long.valueOf(jArr3[iA4] % jArr4[iA4]));
            }
            return arrayList18.toArray(new Long[0]);
        }
        if (z14 && (obj2 instanceof float[])) {
            float[] fArr3 = (float[]) obj;
            int length8 = fArr3.length;
            float[] fArr4 = (float[]) obj2;
            zzdc.zza(this, length8, fArr4.length);
            f fVarZ5 = AbstractC0184a.Z(0, length8);
            ArrayList arrayList19 = new ArrayList(AbstractC0730j.V(fVarZ5));
            Iterator it5 = fVarZ5.iterator();
            while (((e) it5).f1100c) {
                int iA5 = ((e) it5).a();
                arrayList19.add(Float.valueOf(fArr3[iA5] % fArr4[iA5]));
            }
            return arrayList19.toArray(new Float[0]);
        }
        if (!z15 || !(obj2 instanceof double[])) {
            throw new zzae(4, 5, null);
        }
        double[] dArr3 = (double[]) obj;
        int length9 = dArr3.length;
        double[] dArr4 = (double[]) obj2;
        zzdc.zza(this, length9, dArr4.length);
        f fVarZ6 = AbstractC0184a.Z(0, length9);
        ArrayList arrayList20 = new ArrayList(AbstractC0730j.V(fVarZ6));
        Iterator it6 = fVarZ6.iterator();
        while (((e) it6).f1100c) {
            int iA6 = ((e) it6).a();
            arrayList20.add(Double.valueOf(dArr3[iA6] % dArr4[iA6]));
        }
        return arrayList20.toArray(new Double[0]);
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
        try {
            zzcjVar.zzc().zzf(i4, zzb(objZza, objZza2));
        } catch (ArithmeticException e) {
            throw new zzae(4, 6, e);
        }
    }
}
