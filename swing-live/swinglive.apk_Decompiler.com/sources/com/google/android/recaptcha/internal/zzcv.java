package com.google.android.recaptcha.internal;

import P3.a;
import a.AbstractC0184a;
import java.util.Collection;
import java.util.Objects;
import x3.AbstractC0728h;

/* JADX INFO: loaded from: classes.dex */
public final class zzcv implements zzdd {
    public static final zzcv zza = new zzcv();

    private zzcv() {
    }

    @Override // com.google.android.recaptcha.internal.zzdd
    public final void zza(int i4, zzcj zzcjVar, zzpq... zzpqVarArr) throws zzae {
        String strA0;
        String str;
        if (zzpqVarArr.length != 1) {
            throw new zzae(4, 3, null);
        }
        int i5 = 0;
        Object objZza = zzcjVar.zzc().zza(zzpqVarArr[0]);
        if (true != Objects.nonNull(objZza)) {
            objZza = null;
        }
        if (objZza == null) {
            throw new zzae(4, 5, null);
        }
        if (objZza instanceof int[]) {
            int[] iArr = (int[]) objZza;
            StringBuilder sb = new StringBuilder();
            sb.append((CharSequence) "[");
            int length = iArr.length;
            int i6 = 0;
            while (i5 < length) {
                int i7 = iArr[i5];
                i6++;
                if (i6 > 1) {
                    sb.append((CharSequence) ",");
                }
                sb.append((CharSequence) String.valueOf(i7));
                i5++;
            }
            sb.append((CharSequence) "]");
            strA0 = sb.toString();
        } else {
            if (objZza instanceof byte[]) {
                str = new String((byte[]) objZza, a.f1492a);
            } else if (objZza instanceof long[]) {
                long[] jArr = (long[]) objZza;
                StringBuilder sb2 = new StringBuilder();
                sb2.append((CharSequence) "[");
                int length2 = jArr.length;
                int i8 = 0;
                while (i5 < length2) {
                    long j4 = jArr[i5];
                    i8++;
                    if (i8 > 1) {
                        sb2.append((CharSequence) ",");
                    }
                    sb2.append((CharSequence) String.valueOf(j4));
                    i5++;
                }
                sb2.append((CharSequence) "]");
                strA0 = sb2.toString();
            } else if (objZza instanceof short[]) {
                short[] sArr = (short[]) objZza;
                StringBuilder sb3 = new StringBuilder();
                sb3.append((CharSequence) "[");
                int length3 = sArr.length;
                int i9 = 0;
                while (i5 < length3) {
                    short s4 = sArr[i5];
                    i9++;
                    if (i9 > 1) {
                        sb3.append((CharSequence) ",");
                    }
                    sb3.append((CharSequence) String.valueOf((int) s4));
                    i5++;
                }
                sb3.append((CharSequence) "]");
                strA0 = sb3.toString();
            } else if (objZza instanceof float[]) {
                float[] fArr = (float[]) objZza;
                StringBuilder sb4 = new StringBuilder();
                sb4.append((CharSequence) "[");
                int length4 = fArr.length;
                int i10 = 0;
                while (i5 < length4) {
                    float f4 = fArr[i5];
                    i10++;
                    if (i10 > 1) {
                        sb4.append((CharSequence) ",");
                    }
                    sb4.append((CharSequence) String.valueOf(f4));
                    i5++;
                }
                sb4.append((CharSequence) "]");
                strA0 = sb4.toString();
            } else if (objZza instanceof double[]) {
                double[] dArr = (double[]) objZza;
                StringBuilder sb5 = new StringBuilder();
                sb5.append((CharSequence) "[");
                int length5 = dArr.length;
                int i11 = 0;
                while (i5 < length5) {
                    double d5 = dArr[i5];
                    i11++;
                    if (i11 > 1) {
                        sb5.append((CharSequence) ",");
                    }
                    sb5.append((CharSequence) String.valueOf(d5));
                    i5++;
                }
                sb5.append((CharSequence) "]");
                strA0 = sb5.toString();
            } else if (objZza instanceof char[]) {
                str = new String((char[]) objZza);
            } else if (objZza instanceof Object[]) {
                Object[] objArr = (Object[]) objZza;
                StringBuilder sb6 = new StringBuilder();
                sb6.append((CharSequence) "[");
                int length6 = objArr.length;
                int i12 = 0;
                while (i5 < length6) {
                    Object obj = objArr[i5];
                    i12++;
                    if (i12 > 1) {
                        sb6.append((CharSequence) ",");
                    }
                    AbstractC0184a.f(sb6, obj, null);
                    i5++;
                }
                sb6.append((CharSequence) "]");
                strA0 = sb6.toString();
            } else {
                if (!(objZza instanceof Collection)) {
                    throw new zzae(4, 5, null);
                }
                strA0 = AbstractC0728h.a0((Iterable) objZza, ",", "[", "]", null, 56);
            }
            strA0 = str;
        }
        zzcjVar.zzc().zzf(i4, strA0);
    }
}
