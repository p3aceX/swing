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
public final class zzdz implements zzdd {
    public static final zzdz zza = new zzdz();

    private zzdz() {
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
        boolean z4 = obj instanceof Byte;
        if (z4 && (obj2 instanceof Byte)) {
            return Byte.valueOf((byte) (((Number) obj).byteValue() ^ ((Number) obj2).byteValue()));
        }
        boolean z5 = obj instanceof Short;
        if (z5 && (obj2 instanceof Short)) {
            return Short.valueOf((short) (((Number) obj).shortValue() ^ ((Number) obj2).shortValue()));
        }
        boolean z6 = obj instanceof Integer;
        if (z6 && (obj2 instanceof Integer)) {
            return Integer.valueOf(((Number) obj).intValue() ^ ((Number) obj2).intValue());
        }
        boolean z7 = obj instanceof Long;
        if (z7 && (obj2 instanceof Long)) {
            return Long.valueOf(((Number) obj2).longValue() ^ ((Number) obj).longValue());
        }
        int i4 = 0;
        if (obj instanceof String) {
            if (obj2 instanceof Byte) {
                byte[] bytes = ((String) obj).getBytes(a.f1492a);
                int length = bytes.length;
                ArrayList arrayList = new ArrayList(length);
                while (i4 < length) {
                    arrayList.add(Byte.valueOf((byte) (bytes[i4] ^ ((Number) obj2).byteValue())));
                    i4++;
                }
                return AbstractC0728h.f0(arrayList);
            }
            if (obj2 instanceof Integer) {
                char[] charArray = ((String) obj).toCharArray();
                int length2 = charArray.length;
                ArrayList arrayList2 = new ArrayList(length2);
                while (i4 < length2) {
                    arrayList2.add(Integer.valueOf(charArray[i4] ^ ((Number) obj2).intValue()));
                    i4++;
                }
                return AbstractC0728h.h0(arrayList2);
            }
        }
        if (z4 && (obj2 instanceof byte[])) {
            byte[] bArr = (byte[]) obj2;
            ArrayList arrayList3 = new ArrayList(bArr.length);
            for (byte b5 : bArr) {
                arrayList3.add(Byte.valueOf((byte) (b5 ^ ((Number) obj).byteValue())));
            }
            return arrayList3.toArray(new Byte[0]);
        }
        if (z5 && (obj2 instanceof short[])) {
            short[] sArr = (short[]) obj2;
            ArrayList arrayList4 = new ArrayList(sArr.length);
            for (short s4 : sArr) {
                arrayList4.add(Short.valueOf((short) (s4 ^ ((Number) obj).shortValue())));
            }
            return arrayList4.toArray(new Short[0]);
        }
        if (z6 && (obj2 instanceof int[])) {
            int[] iArr = (int[]) obj2;
            ArrayList arrayList5 = new ArrayList(iArr.length);
            for (int i5 : iArr) {
                arrayList5.add(Integer.valueOf(i5 ^ ((Number) obj).intValue()));
            }
            return arrayList5.toArray(new Integer[0]);
        }
        if (z7 && (obj2 instanceof long[])) {
            long[] jArr = (long[]) obj2;
            ArrayList arrayList6 = new ArrayList(jArr.length);
            for (long j4 : jArr) {
                arrayList6.add(Long.valueOf(j4 ^ ((Number) obj).longValue()));
            }
            return arrayList6.toArray(new Long[0]);
        }
        boolean z8 = obj instanceof byte[];
        if (z8 && (obj2 instanceof Byte)) {
            byte[] bArr2 = (byte[]) obj;
            ArrayList arrayList7 = new ArrayList(bArr2.length);
            for (byte b6 : bArr2) {
                arrayList7.add(Byte.valueOf((byte) (b6 ^ ((Number) obj2).byteValue())));
            }
            return arrayList7.toArray(new Byte[0]);
        }
        boolean z9 = obj instanceof short[];
        if (z9 && (obj2 instanceof Short)) {
            short[] sArr2 = (short[]) obj;
            ArrayList arrayList8 = new ArrayList(sArr2.length);
            for (short s5 : sArr2) {
                arrayList8.add(Short.valueOf((short) (s5 ^ ((Number) obj2).shortValue())));
            }
            return arrayList8.toArray(new Short[0]);
        }
        boolean z10 = obj instanceof int[];
        if (z10 && (obj2 instanceof Integer)) {
            int[] iArr2 = (int[]) obj;
            ArrayList arrayList9 = new ArrayList(iArr2.length);
            for (int i6 : iArr2) {
                arrayList9.add(Integer.valueOf(i6 ^ ((Number) obj2).intValue()));
            }
            return arrayList9.toArray(new Integer[0]);
        }
        boolean z11 = obj instanceof long[];
        if (z11 && (obj2 instanceof Long)) {
            long[] jArr2 = (long[]) obj;
            ArrayList arrayList10 = new ArrayList(jArr2.length);
            for (long j5 : jArr2) {
                arrayList10.add(Long.valueOf(j5 ^ ((Number) obj2).longValue()));
            }
            return arrayList10.toArray(new Long[0]);
        }
        if (z8 && (obj2 instanceof byte[])) {
            byte[] bArr3 = (byte[]) obj;
            int length3 = bArr3.length;
            byte[] bArr4 = (byte[]) obj2;
            zzdc.zza(this, length3, bArr4.length);
            f fVarZ = AbstractC0184a.Z(0, length3);
            ArrayList arrayList11 = new ArrayList(AbstractC0730j.V(fVarZ));
            Iterator it = fVarZ.iterator();
            while (((e) it).f1100c) {
                int iA = ((e) it).a();
                arrayList11.add(Byte.valueOf((byte) (bArr4[iA] ^ bArr3[iA])));
            }
            return arrayList11.toArray(new Byte[0]);
        }
        if (z9 && (obj2 instanceof short[])) {
            short[] sArr3 = (short[]) obj;
            int length4 = sArr3.length;
            short[] sArr4 = (short[]) obj2;
            zzdc.zza(this, length4, sArr4.length);
            f fVarZ2 = AbstractC0184a.Z(0, length4);
            ArrayList arrayList12 = new ArrayList(AbstractC0730j.V(fVarZ2));
            Iterator it2 = fVarZ2.iterator();
            while (((e) it2).f1100c) {
                int iA2 = ((e) it2).a();
                arrayList12.add(Short.valueOf((short) (sArr4[iA2] ^ sArr3[iA2])));
            }
            return arrayList12.toArray(new Short[0]);
        }
        if (z10 && (obj2 instanceof int[])) {
            int[] iArr3 = (int[]) obj;
            int length5 = iArr3.length;
            int[] iArr4 = (int[]) obj2;
            zzdc.zza(this, length5, iArr4.length);
            f fVarZ3 = AbstractC0184a.Z(0, length5);
            ArrayList arrayList13 = new ArrayList(AbstractC0730j.V(fVarZ3));
            Iterator it3 = fVarZ3.iterator();
            while (((e) it3).f1100c) {
                int iA3 = ((e) it3).a();
                arrayList13.add(Integer.valueOf(iArr4[iA3] ^ iArr3[iA3]));
            }
            return arrayList13.toArray(new Integer[0]);
        }
        if (!z11 || !(obj2 instanceof long[])) {
            throw new zzae(4, 5, null);
        }
        long[] jArr3 = (long[]) obj;
        int length6 = jArr3.length;
        long[] jArr4 = (long[]) obj2;
        zzdc.zza(this, length6, jArr4.length);
        f fVarZ4 = AbstractC0184a.Z(0, length6);
        ArrayList arrayList14 = new ArrayList(AbstractC0730j.V(fVarZ4));
        Iterator it4 = fVarZ4.iterator();
        while (((e) it4).f1100c) {
            int iA4 = ((e) it4).a();
            arrayList14.add(Long.valueOf(jArr3[iA4] ^ jArr4[iA4]));
        }
        return arrayList14.toArray(new Long[0]);
    }
}
