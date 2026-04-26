package com.google.crypto.tink.shaded.protobuf;

import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public abstract class d0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Class f3779a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final g0 f3780b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final g0 f3781c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final g0 f3782d;

    static {
        Class<?> cls;
        try {
            cls = Class.forName("com.google.crypto.tink.shaded.protobuf.GeneratedMessageV3");
        } catch (Throwable unused) {
            cls = null;
        }
        f3779a = cls;
        f3780b = w(false);
        f3781c = w(true);
        f3782d = new g0();
    }

    public static void A(int i4, List list, K k4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        k4.getClass();
        for (int i5 = 0; i5 < list.size(); i5++) {
            AbstractC0303h abstractC0303h = (AbstractC0303h) list.get(i5);
            C0306k c0306k = (C0306k) k4.f3740a;
            c0306k.F0(i4, 2);
            c0306k.G0(abstractC0303h.size());
            C0302g c0302g = (C0302g) abstractC0303h;
            c0306k.z0(c0302g.f3790d, c0302g.k(), c0302g.size());
        }
    }

    public static void B(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                double dDoubleValue = ((Double) list.get(i5)).doubleValue();
                c0306k.getClass();
                c0306k.C0(i4, Double.doubleToRawLongBits(dDoubleValue));
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Double) list.get(i7)).getClass();
            Logger logger = C0306k.f3810m;
            i6 += 8;
        }
        c0306k.G0(i6);
        while (i5 < list.size()) {
            c0306k.D0(Double.doubleToRawLongBits(((Double) list.get(i5)).doubleValue()));
            i5++;
        }
    }

    public static void C(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        if (!z4) {
            for (int i5 = 0; i5 < list.size(); i5++) {
                int iIntValue = ((Integer) list.get(i5)).intValue();
                c0306k.F0(i4, 0);
                c0306k.E0(iIntValue);
            }
            return;
        }
        c0306k.F0(i4, 2);
        int iT0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iT0 += C0306k.t0(((Integer) list.get(i6)).intValue());
        }
        c0306k.G0(iT0);
        for (int i7 = 0; i7 < list.size(); i7++) {
            c0306k.E0(((Integer) list.get(i7)).intValue());
        }
    }

    public static void D(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0306k.A0(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Integer) list.get(i7)).getClass();
            Logger logger = C0306k.f3810m;
            i6 += 4;
        }
        c0306k.G0(i6);
        while (i5 < list.size()) {
            c0306k.B0(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    public static void E(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0306k.C0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Long) list.get(i7)).getClass();
            Logger logger = C0306k.f3810m;
            i6 += 8;
        }
        c0306k.G0(i6);
        while (i5 < list.size()) {
            c0306k.D0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static void F(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                float fFloatValue = ((Float) list.get(i5)).floatValue();
                c0306k.getClass();
                c0306k.A0(i4, Float.floatToRawIntBits(fFloatValue));
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Float) list.get(i7)).getClass();
            Logger logger = C0306k.f3810m;
            i6 += 4;
        }
        c0306k.G0(i6);
        while (i5 < list.size()) {
            c0306k.B0(Float.floatToRawIntBits(((Float) list.get(i5)).floatValue()));
            i5++;
        }
    }

    public static void G(int i4, List list, K k4, c0 c0Var) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        k4.getClass();
        for (int i5 = 0; i5 < list.size(); i5++) {
            k4.b(i4, list.get(i5), c0Var);
        }
    }

    public static void H(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        if (!z4) {
            for (int i5 = 0; i5 < list.size(); i5++) {
                int iIntValue = ((Integer) list.get(i5)).intValue();
                c0306k.F0(i4, 0);
                c0306k.E0(iIntValue);
            }
            return;
        }
        c0306k.F0(i4, 2);
        int iT0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iT0 += C0306k.t0(((Integer) list.get(i6)).intValue());
        }
        c0306k.G0(iT0);
        for (int i7 = 0; i7 < list.size(); i7++) {
            c0306k.E0(((Integer) list.get(i7)).intValue());
        }
    }

    public static void I(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0306k.H0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iX0 += C0306k.x0(((Long) list.get(i6)).longValue());
        }
        c0306k.G0(iX0);
        while (i5 < list.size()) {
            c0306k.I0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static void J(int i4, List list, K k4, c0 c0Var) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        k4.getClass();
        for (int i5 = 0; i5 < list.size(); i5++) {
            k4.c(i4, list.get(i5), c0Var);
        }
    }

    public static void K(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0306k.A0(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Integer) list.get(i7)).getClass();
            Logger logger = C0306k.f3810m;
            i6 += 4;
        }
        c0306k.G0(i6);
        while (i5 < list.size()) {
            c0306k.B0(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    public static void L(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0306k.C0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Long) list.get(i7)).getClass();
            Logger logger = C0306k.f3810m;
            i6 += 8;
        }
        c0306k.G0(i6);
        while (i5 < list.size()) {
            c0306k.D0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static void M(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        if (!z4) {
            for (int i5 = 0; i5 < list.size(); i5++) {
                int iIntValue = ((Integer) list.get(i5)).intValue();
                c0306k.F0(i4, 0);
                c0306k.G0((iIntValue >> 31) ^ (iIntValue << 1));
            }
            return;
        }
        c0306k.F0(i4, 2);
        int iW0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            int iIntValue2 = ((Integer) list.get(i6)).intValue();
            iW0 += C0306k.w0((iIntValue2 >> 31) ^ (iIntValue2 << 1));
        }
        c0306k.G0(iW0);
        for (int i7 = 0; i7 < list.size(); i7++) {
            int iIntValue3 = ((Integer) list.get(i7)).intValue();
            c0306k.G0((iIntValue3 >> 31) ^ (iIntValue3 << 1));
        }
    }

    public static void N(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                long jLongValue = ((Long) list.get(i5)).longValue();
                c0306k.H0(i4, (jLongValue >> 63) ^ (jLongValue << 1));
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            long jLongValue2 = ((Long) list.get(i6)).longValue();
            iX0 += C0306k.x0((jLongValue2 >> 63) ^ (jLongValue2 << 1));
        }
        c0306k.G0(iX0);
        while (i5 < list.size()) {
            long jLongValue3 = ((Long) list.get(i5)).longValue();
            c0306k.I0((jLongValue3 >> 63) ^ (jLongValue3 << 1));
            i5++;
        }
    }

    public static void O(int i4, List list, K k4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        k4.getClass();
        boolean z4 = list instanceof E;
        C0306k c0306k = (C0306k) k4.f3740a;
        if (!z4) {
            for (int i5 = 0; i5 < list.size(); i5++) {
                String str = (String) list.get(i5);
                c0306k.F0(i4, 2);
                int i6 = c0306k.f3815l;
                try {
                    int iW0 = C0306k.w0(str.length() * 3);
                    int iW02 = C0306k.w0(str.length());
                    byte[] bArr = c0306k.f3813j;
                    int i7 = c0306k.f3814k;
                    if (iW02 == iW0) {
                        int i8 = i6 + iW02;
                        c0306k.f3815l = i8;
                        int iC = r0.f3834a.C(str, bArr, i8, i7 - i8);
                        c0306k.f3815l = i6;
                        c0306k.G0((iC - i6) - iW02);
                        c0306k.f3815l = iC;
                    } else {
                        c0306k.G0(r0.b(str));
                        int i9 = c0306k.f3815l;
                        c0306k.f3815l = r0.f3834a.C(str, bArr, i9, i7 - i9);
                    }
                } catch (q0 e) {
                    c0306k.f3815l = i6;
                    C0306k.f3810m.log(Level.WARNING, "Converting ill-formed UTF-16. Your Protocol Buffer will not round trip correctly!", (Throwable) e);
                    byte[] bytes = str.getBytes(AbstractC0320z.f3839a);
                    try {
                        c0306k.G0(bytes.length);
                        c0306k.z0(bytes, 0, bytes.length);
                    } catch (IndexOutOfBoundsException e4) {
                        throw new io.ktor.utils.io.E(e4);
                    }
                } catch (IndexOutOfBoundsException e5) {
                    throw new io.ktor.utils.io.E(e5);
                }
            }
            return;
        }
        E e6 = (E) list;
        for (int i10 = 0; i10 < list.size(); i10++) {
            Object objB = e6.b(i10);
            if (objB instanceof String) {
                String str2 = (String) objB;
                c0306k.F0(i4, 2);
                int i11 = c0306k.f3815l;
                try {
                    int iW03 = C0306k.w0(str2.length() * 3);
                    int iW04 = C0306k.w0(str2.length());
                    byte[] bArr2 = c0306k.f3813j;
                    int i12 = c0306k.f3814k;
                    if (iW04 == iW03) {
                        int i13 = i11 + iW04;
                        c0306k.f3815l = i13;
                        int iC2 = r0.f3834a.C(str2, bArr2, i13, i12 - i13);
                        c0306k.f3815l = i11;
                        c0306k.G0((iC2 - i11) - iW04);
                        c0306k.f3815l = iC2;
                    } else {
                        c0306k.G0(r0.b(str2));
                        int i14 = c0306k.f3815l;
                        c0306k.f3815l = r0.f3834a.C(str2, bArr2, i14, i12 - i14);
                    }
                } catch (q0 e7) {
                    c0306k.f3815l = i11;
                    C0306k.f3810m.log(Level.WARNING, "Converting ill-formed UTF-16. Your Protocol Buffer will not round trip correctly!", (Throwable) e7);
                    byte[] bytes2 = str2.getBytes(AbstractC0320z.f3839a);
                    try {
                        c0306k.G0(bytes2.length);
                        c0306k.z0(bytes2, 0, bytes2.length);
                    } catch (IndexOutOfBoundsException e8) {
                        throw new io.ktor.utils.io.E(e8);
                    }
                } catch (IndexOutOfBoundsException e9) {
                    throw new io.ktor.utils.io.E(e9);
                }
            } else {
                AbstractC0303h abstractC0303h = (AbstractC0303h) objB;
                c0306k.F0(i4, 2);
                c0306k.G0(abstractC0303h.size());
                C0302g c0302g = (C0302g) abstractC0303h;
                c0306k.z0(c0302g.f3790d, c0302g.k(), c0302g.size());
            }
        }
    }

    public static void P(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        if (!z4) {
            for (int i5 = 0; i5 < list.size(); i5++) {
                int iIntValue = ((Integer) list.get(i5)).intValue();
                c0306k.F0(i4, 0);
                c0306k.G0(iIntValue);
            }
            return;
        }
        c0306k.F0(i4, 2);
        int iW0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iW0 += C0306k.w0(((Integer) list.get(i6)).intValue());
        }
        c0306k.G0(iW0);
        for (int i7 = 0; i7 < list.size(); i7++) {
            c0306k.G0(((Integer) list.get(i7)).intValue());
        }
    }

    public static void Q(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0306k.H0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0306k.F0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iX0 += C0306k.x0(((Long) list.get(i6)).longValue());
        }
        c0306k.G0(iX0);
        while (i5 < list.size()) {
            c0306k.I0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static int a(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iV0 = C0306k.v0(i4) * size;
        for (int i5 = 0; i5 < list.size(); i5++) {
            iV0 += C0306k.p0((AbstractC0303h) list.get(i5));
        }
        return iV0;
    }

    public static int b(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0306k.v0(i4) * size) + c(list);
    }

    public static int c(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        if (list instanceof AbstractC0317w) {
            AbstractC0317w abstractC0317w = (AbstractC0317w) list;
            if (size <= 0) {
                return 0;
            }
            abstractC0317w.h(0);
            throw null;
        }
        int iT0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iT0 += C0306k.t0(((Integer) list.get(i4)).intValue());
        }
        return iT0;
    }

    public static int d(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return C0306k.q0(i4) * size;
    }

    public static int e(List list) {
        return list.size() * 4;
    }

    public static int f(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return C0306k.r0(i4) * size;
    }

    public static int g(List list) {
        return list.size() * 8;
    }

    public static int h(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0306k.v0(i4) * size) + i(list);
    }

    public static int i(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        if (list instanceof AbstractC0317w) {
            AbstractC0317w abstractC0317w = (AbstractC0317w) list;
            if (size <= 0) {
                return 0;
            }
            abstractC0317w.h(0);
            throw null;
        }
        int iT0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iT0 += C0306k.t0(((Integer) list.get(i4)).intValue());
        }
        return iT0;
    }

    public static int j(int i4, List list) {
        if (list.size() == 0) {
            return 0;
        }
        return (C0306k.v0(i4) * list.size()) + k(list);
    }

    public static int k(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        if (list instanceof I) {
            I i4 = (I) list;
            if (size <= 0) {
                return 0;
            }
            i4.h(0);
            throw null;
        }
        int iX0 = 0;
        for (int i5 = 0; i5 < size; i5++) {
            iX0 += C0306k.x0(((Long) list.get(i5)).longValue());
        }
        return iX0;
    }

    public static int l(int i4, List list, c0 c0Var) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iV0 = C0306k.v0(i4) * size;
        for (int i5 = 0; i5 < size; i5++) {
            int iB = ((AbstractC0296a) list.get(i5)).b(c0Var);
            iV0 += C0306k.w0(iB) + iB;
        }
        return iV0;
    }

    public static int m(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0306k.v0(i4) * size) + n(list);
    }

    public static int n(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        if (list instanceof AbstractC0317w) {
            AbstractC0317w abstractC0317w = (AbstractC0317w) list;
            if (size <= 0) {
                return 0;
            }
            abstractC0317w.h(0);
            throw null;
        }
        int iW0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            int iIntValue = ((Integer) list.get(i4)).intValue();
            iW0 += C0306k.w0((iIntValue >> 31) ^ (iIntValue << 1));
        }
        return iW0;
    }

    public static int o(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0306k.v0(i4) * size) + p(list);
    }

    public static int p(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        if (list instanceof I) {
            I i4 = (I) list;
            if (size <= 0) {
                return 0;
            }
            i4.h(0);
            throw null;
        }
        int iX0 = 0;
        for (int i5 = 0; i5 < size; i5++) {
            long jLongValue = ((Long) list.get(i5)).longValue();
            iX0 += C0306k.x0((jLongValue >> 63) ^ (jLongValue << 1));
        }
        return iX0;
    }

    public static int q(int i4, List list) {
        int size = list.size();
        int i5 = 0;
        if (size == 0) {
            return 0;
        }
        int iV0 = C0306k.v0(i4) * size;
        if (!(list instanceof E)) {
            while (i5 < size) {
                Object obj = list.get(i5);
                iV0 = (obj instanceof AbstractC0303h ? C0306k.p0((AbstractC0303h) obj) : C0306k.u0((String) obj)) + iV0;
                i5++;
            }
            return iV0;
        }
        E e = (E) list;
        while (i5 < size) {
            Object objB = e.b(i5);
            iV0 = (objB instanceof AbstractC0303h ? C0306k.p0((AbstractC0303h) objB) : C0306k.u0((String) objB)) + iV0;
            i5++;
        }
        return iV0;
    }

    public static int r(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0306k.v0(i4) * size) + s(list);
    }

    public static int s(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        if (list instanceof AbstractC0317w) {
            AbstractC0317w abstractC0317w = (AbstractC0317w) list;
            if (size <= 0) {
                return 0;
            }
            abstractC0317w.h(0);
            throw null;
        }
        int iW0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iW0 += C0306k.w0(((Integer) list.get(i4)).intValue());
        }
        return iW0;
    }

    public static int t(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0306k.v0(i4) * size) + u(list);
    }

    public static int u(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        if (list instanceof I) {
            I i4 = (I) list;
            if (size <= 0) {
                return 0;
            }
            i4.h(0);
            throw null;
        }
        int iX0 = 0;
        for (int i5 = 0; i5 < size; i5++) {
            iX0 += C0306k.x0(((Long) list.get(i5)).longValue());
        }
        return iX0;
    }

    public static g0 w(boolean z4) {
        Class<?> cls;
        try {
            cls = Class.forName("com.google.crypto.tink.shaded.protobuf.UnknownFieldSetSchema");
        } catch (Throwable unused) {
            cls = null;
        }
        if (cls != null) {
            try {
                return (g0) cls.getConstructor(Boolean.TYPE).newInstance(Boolean.valueOf(z4));
            } catch (Throwable unused2) {
            }
        }
        return null;
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    public static void x(g0 g0Var, Object obj, Object obj2) {
        g0Var.getClass();
        AbstractC0316v abstractC0316v = (AbstractC0316v) obj;
        f0 f0Var = abstractC0316v.unknownFields;
        f0 f0Var2 = ((AbstractC0316v) obj2).unknownFields;
        f0 f0Var3 = f0.f3785f;
        if (!f0Var3.equals(f0Var2)) {
            if (f0Var3.equals(f0Var)) {
                int i4 = f0Var.f3786a + f0Var2.f3786a;
                int[] iArrCopyOf = Arrays.copyOf(f0Var.f3787b, i4);
                System.arraycopy(f0Var2.f3787b, 0, iArrCopyOf, f0Var.f3786a, f0Var2.f3786a);
                Object[] objArrCopyOf = Arrays.copyOf(f0Var.f3788c, i4);
                System.arraycopy(f0Var2.f3788c, 0, objArrCopyOf, f0Var.f3786a, f0Var2.f3786a);
                f0Var = new f0(i4, iArrCopyOf, objArrCopyOf, true);
            } else {
                f0Var.getClass();
                if (!f0Var2.equals(f0Var3)) {
                    if (!f0Var.e) {
                        throw new UnsupportedOperationException();
                    }
                    int i5 = f0Var.f3786a + f0Var2.f3786a;
                    f0Var.a(i5);
                    System.arraycopy(f0Var2.f3787b, 0, f0Var.f3787b, f0Var.f3786a, f0Var2.f3786a);
                    System.arraycopy(f0Var2.f3788c, 0, f0Var.f3788c, f0Var.f3786a, f0Var2.f3786a);
                    f0Var.f3786a = i5;
                }
            }
        }
        abstractC0316v.unknownFields = f0Var;
    }

    public static boolean y(Object obj, Object obj2) {
        if (obj != obj2) {
            return obj != null && obj.equals(obj2);
        }
        return true;
    }

    public static void z(int i4, List list, K k4, boolean z4) throws io.ktor.utils.io.E {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0306k c0306k = (C0306k) k4.f3740a;
        if (!z4) {
            for (int i5 = 0; i5 < list.size(); i5++) {
                boolean zBooleanValue = ((Boolean) list.get(i5)).booleanValue();
                c0306k.F0(i4, 0);
                c0306k.y0(zBooleanValue ? (byte) 1 : (byte) 0);
            }
            return;
        }
        c0306k.F0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Boolean) list.get(i7)).getClass();
            Logger logger = C0306k.f3810m;
            i6++;
        }
        c0306k.G0(i6);
        for (int i8 = 0; i8 < list.size(); i8++) {
            c0306k.y0(((Boolean) list.get(i8)).booleanValue() ? (byte) 1 : (byte) 0);
        }
    }

    public static Object v(Object obj, int i4, List list, Object obj2, g0 g0Var) {
        return obj2;
    }
}
