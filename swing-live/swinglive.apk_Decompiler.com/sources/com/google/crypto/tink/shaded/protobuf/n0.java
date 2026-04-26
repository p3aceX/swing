package com.google.crypto.tink.shaded.protobuf;

import java.lang.reflect.Field;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
public abstract class n0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Unsafe f3820a;

    public n0(Unsafe unsafe) {
        this.f3820a = unsafe;
    }

    public final int a(Class cls) {
        return this.f3820a.arrayBaseOffset(cls);
    }

    public final int b(Class cls) {
        return this.f3820a.arrayIndexScale(cls);
    }

    public abstract boolean c(Object obj, long j4);

    public abstract byte d(Object obj, long j4);

    public abstract double e(Object obj, long j4);

    public abstract float f(Object obj, long j4);

    public final int g(Object obj, long j4) {
        return this.f3820a.getInt(obj, j4);
    }

    public final long h(Object obj, long j4) {
        return this.f3820a.getLong(obj, j4);
    }

    public final Object i(Object obj, long j4) {
        return this.f3820a.getObject(obj, j4);
    }

    public final long j(Field field) {
        return this.f3820a.objectFieldOffset(field);
    }

    public abstract void k(Object obj, long j4, boolean z4);

    public abstract void l(Object obj, long j4, byte b5);

    public abstract void m(Object obj, long j4, double d5);

    public abstract void n(Object obj, long j4, float f4);

    public final void o(Object obj, int i4, long j4) {
        this.f3820a.putInt(obj, j4, i4);
    }

    public final void p(Object obj, long j4, long j5) {
        this.f3820a.putLong(obj, j4, j5);
    }

    public final void q(Object obj, long j4, Object obj2) {
        this.f3820a.putObject(obj, j4, obj2);
    }

    public boolean r() {
        Unsafe unsafe = this.f3820a;
        if (unsafe == null) {
            return false;
        }
        try {
            Class<?> cls = unsafe.getClass();
            cls.getMethod("objectFieldOffset", Field.class);
            cls.getMethod("arrayBaseOffset", Class.class);
            cls.getMethod("arrayIndexScale", Class.class);
            Class cls2 = Long.TYPE;
            cls.getMethod("getInt", Object.class, cls2);
            cls.getMethod("putInt", Object.class, cls2, Integer.TYPE);
            cls.getMethod("getLong", Object.class, cls2);
            cls.getMethod("putLong", Object.class, cls2, cls2);
            cls.getMethod("getObject", Object.class, cls2);
            cls.getMethod("putObject", Object.class, cls2, Object.class);
            return true;
        } catch (Throwable th) {
            o0.a(th);
            return false;
        }
    }

    public abstract boolean s();
}
