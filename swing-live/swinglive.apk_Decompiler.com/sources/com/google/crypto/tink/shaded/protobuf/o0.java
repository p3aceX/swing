package com.google.crypto.tink.shaded.protobuf;

import java.lang.reflect.Field;
import java.nio.Buffer;
import java.nio.ByteOrder;
import java.security.AccessController;
import java.util.logging.Level;
import java.util.logging.Logger;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
public abstract class o0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Unsafe f3821a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Class f3822b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final n0 f3823c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final boolean f3824d;
    public static final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final long f3825f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final boolean f3826g;

    static {
        Unsafe unsafeJ = j();
        f3821a = unsafeJ;
        f3822b = AbstractC0298c.f3777a;
        boolean zF = f(Long.TYPE);
        boolean zF2 = f(Integer.TYPE);
        n0 m0Var = null;
        if (unsafeJ != null) {
            if (!AbstractC0298c.a()) {
                m0Var = new m0(unsafeJ);
            } else if (zF) {
                m0Var = new l0(unsafeJ, 1);
            } else if (zF2) {
                m0Var = new l0(unsafeJ, 0);
            }
        }
        f3823c = m0Var;
        f3824d = m0Var == null ? false : m0Var.s();
        e = m0Var == null ? false : m0Var.r();
        f3825f = c(byte[].class);
        c(boolean[].class);
        d(boolean[].class);
        c(int[].class);
        d(int[].class);
        c(long[].class);
        d(long[].class);
        c(float[].class);
        d(float[].class);
        c(double[].class);
        d(double[].class);
        c(Object[].class);
        d(Object[].class);
        Field fieldE = e();
        if (fieldE != null && m0Var != null) {
            m0Var.j(fieldE);
        }
        f3826g = ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN;
    }

    public static void a(Throwable th) {
        Logger.getLogger(o0.class.getName()).log(Level.WARNING, "platform method missing - proto runtime falling back to safer methods: " + th);
    }

    public static Object b(Class cls) {
        try {
            return f3821a.allocateInstance(cls);
        } catch (InstantiationException e4) {
            throw new IllegalStateException(e4);
        }
    }

    public static int c(Class cls) {
        if (e) {
            return f3823c.a(cls);
        }
        return -1;
    }

    public static void d(Class cls) {
        if (e) {
            f3823c.b(cls);
        }
    }

    public static Field e() {
        Field declaredField;
        Field declaredField2;
        if (AbstractC0298c.a()) {
            try {
                declaredField2 = Buffer.class.getDeclaredField("effectiveDirectAddress");
            } catch (Throwable unused) {
                declaredField2 = null;
            }
            if (declaredField2 != null) {
                return declaredField2;
            }
        }
        try {
            declaredField = Buffer.class.getDeclaredField("address");
        } catch (Throwable unused2) {
            declaredField = null;
        }
        if (declaredField == null || declaredField.getType() != Long.TYPE) {
            return null;
        }
        return declaredField;
    }

    public static boolean f(Class cls) {
        if (!AbstractC0298c.a()) {
            return false;
        }
        try {
            Class cls2 = f3822b;
            Class cls3 = Boolean.TYPE;
            cls2.getMethod("peekLong", cls, cls3);
            cls2.getMethod("pokeLong", cls, Long.TYPE, cls3);
            Class cls4 = Integer.TYPE;
            cls2.getMethod("pokeInt", cls, cls4, cls3);
            cls2.getMethod("peekInt", cls, cls3);
            cls2.getMethod("pokeByte", cls, Byte.TYPE);
            cls2.getMethod("peekByte", cls);
            cls2.getMethod("pokeByteArray", cls, byte[].class, cls4, cls4);
            cls2.getMethod("peekByteArray", cls, byte[].class, cls4, cls4);
            return true;
        } catch (Throwable unused) {
            return false;
        }
    }

    public static byte g(byte[] bArr, long j4) {
        return f3823c.d(bArr, f3825f + j4);
    }

    public static byte h(Object obj, long j4) {
        return (byte) ((f3823c.g(obj, (-4) & j4) >>> ((int) (((~j4) & 3) << 3))) & 255);
    }

    public static byte i(Object obj, long j4) {
        return (byte) ((f3823c.g(obj, (-4) & j4) >>> ((int) ((j4 & 3) << 3))) & 255);
    }

    public static Unsafe j() {
        try {
            return (Unsafe) AccessController.doPrivileged(new k0());
        } catch (Throwable unused) {
            return null;
        }
    }

    public static void k(byte[] bArr, long j4, byte b5) {
        f3823c.l(bArr, f3825f + j4, b5);
    }

    public static void l(Object obj, long j4, byte b5) {
        long j5 = (-4) & j4;
        int iG = f3823c.g(obj, j5);
        int i4 = ((~((int) j4)) & 3) << 3;
        n(obj, ((255 & b5) << i4) | (iG & (~(255 << i4))), j5);
    }

    public static void m(Object obj, long j4, byte b5) {
        long j5 = (-4) & j4;
        int i4 = (((int) j4) & 3) << 3;
        n(obj, ((255 & b5) << i4) | (f3823c.g(obj, j5) & (~(255 << i4))), j5);
    }

    public static void n(Object obj, int i4, long j4) {
        f3823c.o(obj, i4, j4);
    }

    public static void o(Object obj, long j4, long j5) {
        f3823c.p(obj, j4, j5);
    }

    public static void p(Object obj, long j4, Object obj2) {
        f3823c.q(obj, j4, obj2);
    }
}
