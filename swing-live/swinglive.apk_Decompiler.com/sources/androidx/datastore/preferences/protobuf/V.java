package androidx.datastore.preferences.protobuf;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

/* JADX INFO: loaded from: classes.dex */
public abstract class V {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Class f2937a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final c0 f2938b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final c0 f2939c;

    static {
        Class<?> cls;
        Class<?> cls2;
        Q q4 = Q.f2927c;
        c0 c0Var = null;
        try {
            cls = Class.forName("androidx.datastore.preferences.protobuf.GeneratedMessage");
        } catch (Throwable unused) {
            cls = null;
        }
        f2937a = cls;
        try {
            Q q5 = Q.f2927c;
            try {
                cls2 = Class.forName("androidx.datastore.preferences.protobuf.UnknownFieldSetSchema");
            } catch (Throwable unused2) {
                cls2 = null;
            }
            if (cls2 != null) {
                c0Var = (c0) cls2.getConstructor(new Class[0]).newInstance(new Object[0]);
            }
        } catch (Throwable unused3) {
        }
        f2938b = c0Var;
        f2939c = new c0();
    }

    public static int a(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iX0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iX0 += C0200k.x0(((Integer) list.get(i4)).intValue());
        }
        return iX0;
    }

    public static int b(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0200k.v0(i4) + 4) * size;
    }

    public static int c(int i4, List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return (C0200k.v0(i4) + 8) * size;
    }

    public static int d(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iX0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iX0 += C0200k.x0(((Integer) list.get(i4)).intValue());
        }
        return iX0;
    }

    public static int e(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iX0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iX0 += C0200k.x0(((Long) list.get(i4)).longValue());
        }
        return iX0;
    }

    public static int f(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iW0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            int iIntValue = ((Integer) list.get(i4)).intValue();
            iW0 += C0200k.w0((iIntValue >> 31) ^ (iIntValue << 1));
        }
        return iW0;
    }

    public static int g(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iX0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            long jLongValue = ((Long) list.get(i4)).longValue();
            iX0 += C0200k.x0((jLongValue >> 63) ^ (jLongValue << 1));
        }
        return iX0;
    }

    public static int h(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iW0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iW0 += C0200k.w0(((Integer) list.get(i4)).intValue());
        }
        return iW0;
    }

    public static int i(List list) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        int iX0 = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iX0 += C0200k.x0(((Long) list.get(i4)).longValue());
        }
        return iX0;
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
    public static void k(c0 c0Var, Object obj, Object obj2) {
        c0Var.getClass();
        AbstractC0209u abstractC0209u = (AbstractC0209u) obj;
        b0 b0Var = abstractC0209u.unknownFields;
        b0 b0Var2 = ((AbstractC0209u) obj2).unknownFields;
        b0 b0Var3 = b0.f2954f;
        if (!b0Var3.equals(b0Var2)) {
            if (b0Var3.equals(b0Var)) {
                int i4 = b0Var.f2955a + b0Var2.f2955a;
                int[] iArrCopyOf = Arrays.copyOf(b0Var.f2956b, i4);
                System.arraycopy(b0Var2.f2956b, 0, iArrCopyOf, b0Var.f2955a, b0Var2.f2955a);
                Object[] objArrCopyOf = Arrays.copyOf(b0Var.f2957c, i4);
                System.arraycopy(b0Var2.f2957c, 0, objArrCopyOf, b0Var.f2955a, b0Var2.f2955a);
                b0Var = new b0(i4, iArrCopyOf, objArrCopyOf, true);
            } else {
                b0Var.getClass();
                if (!b0Var2.equals(b0Var3)) {
                    if (!b0Var.e) {
                        throw new UnsupportedOperationException();
                    }
                    int i5 = b0Var.f2955a + b0Var2.f2955a;
                    b0Var.a(i5);
                    System.arraycopy(b0Var2.f2956b, 0, b0Var.f2956b, b0Var.f2955a, b0Var2.f2955a);
                    System.arraycopy(b0Var2.f2957c, 0, b0Var.f2957c, b0Var.f2955a, b0Var2.f2955a);
                    b0Var.f2955a = i5;
                }
            }
        }
        abstractC0209u.unknownFields = b0Var;
    }

    public static boolean l(Object obj, Object obj2) {
        if (obj != obj2) {
            return obj != null && obj.equals(obj2);
        }
        return true;
    }

    public static void m(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.C0(i4, ((Boolean) list.get(i5)).booleanValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Boolean) list.get(i7)).getClass();
            Logger logger = C0200k.f2997n;
            i6++;
        }
        c0200k.Q0(i6);
        while (i5 < list.size()) {
            c0200k.A0(((Boolean) list.get(i5)).booleanValue() ? (byte) 1 : (byte) 0);
            i5++;
        }
    }

    public static void n(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                double dDoubleValue = ((Double) list.get(i5)).doubleValue();
                c0200k.getClass();
                c0200k.H0(i4, Double.doubleToRawLongBits(dDoubleValue));
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Double) list.get(i7)).getClass();
            Logger logger = C0200k.f2997n;
            i6 += 8;
        }
        c0200k.Q0(i6);
        while (i5 < list.size()) {
            c0200k.I0(Double.doubleToRawLongBits(((Double) list.get(i5)).doubleValue()));
            i5++;
        }
    }

    public static void o(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.J0(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iX0 += C0200k.x0(((Integer) list.get(i6)).intValue());
        }
        c0200k.Q0(iX0);
        while (i5 < list.size()) {
            c0200k.K0(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    public static void p(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.F0(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Integer) list.get(i7)).getClass();
            Logger logger = C0200k.f2997n;
            i6 += 4;
        }
        c0200k.Q0(i6);
        while (i5 < list.size()) {
            c0200k.G0(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    public static void q(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.H0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Long) list.get(i7)).getClass();
            Logger logger = C0200k.f2997n;
            i6 += 8;
        }
        c0200k.Q0(i6);
        while (i5 < list.size()) {
            c0200k.I0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static void r(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                float fFloatValue = ((Float) list.get(i5)).floatValue();
                c0200k.getClass();
                c0200k.F0(i4, Float.floatToRawIntBits(fFloatValue));
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Float) list.get(i7)).getClass();
            Logger logger = C0200k.f2997n;
            i6 += 4;
        }
        c0200k.Q0(i6);
        while (i5 < list.size()) {
            c0200k.G0(Float.floatToRawIntBits(((Float) list.get(i5)).floatValue()));
            i5++;
        }
    }

    public static void s(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.J0(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iX0 += C0200k.x0(((Integer) list.get(i6)).intValue());
        }
        c0200k.Q0(iX0);
        while (i5 < list.size()) {
            c0200k.K0(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    public static void t(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.R0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iX0 += C0200k.x0(((Long) list.get(i6)).longValue());
        }
        c0200k.Q0(iX0);
        while (i5 < list.size()) {
            c0200k.S0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static void u(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.F0(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Integer) list.get(i7)).getClass();
            Logger logger = C0200k.f2997n;
            i6 += 4;
        }
        c0200k.Q0(i6);
        while (i5 < list.size()) {
            c0200k.G0(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    public static void v(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.H0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int i6 = 0;
        for (int i7 = 0; i7 < list.size(); i7++) {
            ((Long) list.get(i7)).getClass();
            Logger logger = C0200k.f2997n;
            i6 += 8;
        }
        c0200k.Q0(i6);
        while (i5 < list.size()) {
            c0200k.I0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static void w(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                int iIntValue = ((Integer) list.get(i5)).intValue();
                c0200k.P0(i4, (iIntValue >> 31) ^ (iIntValue << 1));
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int iW0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            int iIntValue2 = ((Integer) list.get(i6)).intValue();
            iW0 += C0200k.w0((iIntValue2 >> 31) ^ (iIntValue2 << 1));
        }
        c0200k.Q0(iW0);
        while (i5 < list.size()) {
            int iIntValue3 = ((Integer) list.get(i5)).intValue();
            c0200k.Q0((iIntValue3 >> 31) ^ (iIntValue3 << 1));
            i5++;
        }
    }

    public static void x(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                long jLongValue = ((Long) list.get(i5)).longValue();
                c0200k.R0(i4, (jLongValue >> 63) ^ (jLongValue << 1));
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            long jLongValue2 = ((Long) list.get(i6)).longValue();
            iX0 += C0200k.x0((jLongValue2 >> 63) ^ (jLongValue2 << 1));
        }
        c0200k.Q0(iX0);
        while (i5 < list.size()) {
            long jLongValue3 = ((Long) list.get(i5)).longValue();
            c0200k.S0((jLongValue3 >> 63) ^ (jLongValue3 << 1));
            i5++;
        }
    }

    public static void y(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.P0(i4, ((Integer) list.get(i5)).intValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int iW0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iW0 += C0200k.w0(((Integer) list.get(i6)).intValue());
        }
        c0200k.Q0(iW0);
        while (i5 < list.size()) {
            c0200k.Q0(((Integer) list.get(i5)).intValue());
            i5++;
        }
    }

    public static void z(int i4, List list, D d5, boolean z4) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        C0200k c0200k = (C0200k) d5.f2898a;
        int i5 = 0;
        if (!z4) {
            while (i5 < list.size()) {
                c0200k.R0(i4, ((Long) list.get(i5)).longValue());
                i5++;
            }
            return;
        }
        c0200k.O0(i4, 2);
        int iX0 = 0;
        for (int i6 = 0; i6 < list.size(); i6++) {
            iX0 += C0200k.x0(((Long) list.get(i6)).longValue());
        }
        c0200k.Q0(iX0);
        while (i5 < list.size()) {
            c0200k.S0(((Long) list.get(i5)).longValue());
            i5++;
        }
    }

    public static Object j(Object obj, int i4, InterfaceC0210v interfaceC0210v, Object obj2, c0 c0Var) {
        return obj2;
    }
}
