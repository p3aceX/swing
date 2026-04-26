package androidx.datastore.preferences.protobuf;

import java.lang.reflect.Field;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
public abstract class g0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Unsafe f2972a;

    public g0(Unsafe unsafe) {
        this.f2972a = unsafe;
    }

    public final int a(Class cls) {
        return this.f2972a.arrayBaseOffset(cls);
    }

    public final int b(Class cls) {
        return this.f2972a.arrayIndexScale(cls);
    }

    public abstract boolean c(Object obj, long j4);

    public abstract double d(Object obj, long j4);

    public abstract float e(Object obj, long j4);

    public final int f(Object obj, long j4) {
        return this.f2972a.getInt(obj, j4);
    }

    public final long g(Object obj, long j4) {
        return this.f2972a.getLong(obj, j4);
    }

    public final Object h(Object obj, long j4) {
        return this.f2972a.getObject(obj, j4);
    }

    public final long i(Field field) {
        return this.f2972a.objectFieldOffset(field);
    }

    public abstract void j(Object obj, long j4, boolean z4);

    public abstract void k(Object obj, long j4, byte b5);

    public abstract void l(Object obj, long j4, double d5);

    public abstract void m(Object obj, long j4, float f4);

    public final void n(Object obj, int i4, long j4) {
        this.f2972a.putInt(obj, j4, i4);
    }

    public final void o(Object obj, long j4, long j5) {
        this.f2972a.putLong(obj, j4, j5);
    }

    public final void p(Object obj, long j4, Object obj2) {
        this.f2972a.putObject(obj, j4, obj2);
    }

    public boolean q() {
        Unsafe unsafe = this.f2972a;
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
            h0.a(th);
            return false;
        }
    }

    public abstract boolean r();
}
