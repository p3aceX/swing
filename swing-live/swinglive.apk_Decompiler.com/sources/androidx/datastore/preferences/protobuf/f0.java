package androidx.datastore.preferences.protobuf;

import java.lang.reflect.Field;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
public final class f0 extends g0 {
    @Override // androidx.datastore.preferences.protobuf.g0
    public final boolean c(Object obj, long j4) {
        return this.f2972a.getBoolean(obj, j4);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final double d(Object obj, long j4) {
        return this.f2972a.getDouble(obj, j4);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final float e(Object obj, long j4) {
        return this.f2972a.getFloat(obj, j4);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void j(Object obj, long j4, boolean z4) {
        this.f2972a.putBoolean(obj, j4, z4);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void k(Object obj, long j4, byte b5) {
        this.f2972a.putByte(obj, j4, b5);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void l(Object obj, long j4, double d5) {
        this.f2972a.putDouble(obj, j4, d5);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final void m(Object obj, long j4, float f4) {
        this.f2972a.putFloat(obj, j4, f4);
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final boolean q() {
        if (!super.q()) {
            return false;
        }
        try {
            Class<?> cls = this.f2972a.getClass();
            Class cls2 = Long.TYPE;
            cls.getMethod("getByte", Object.class, cls2);
            cls.getMethod("putByte", Object.class, cls2, Byte.TYPE);
            cls.getMethod("getBoolean", Object.class, cls2);
            cls.getMethod("putBoolean", Object.class, cls2, Boolean.TYPE);
            cls.getMethod("getFloat", Object.class, cls2);
            cls.getMethod("putFloat", Object.class, cls2, Float.TYPE);
            cls.getMethod("getDouble", Object.class, cls2);
            cls.getMethod("putDouble", Object.class, cls2, Double.TYPE);
            return true;
        } catch (Throwable th) {
            h0.a(th);
            return false;
        }
    }

    @Override // androidx.datastore.preferences.protobuf.g0
    public final boolean r() {
        Unsafe unsafe = this.f2972a;
        if (unsafe != null) {
            try {
                Class<?> cls = unsafe.getClass();
                cls.getMethod("objectFieldOffset", Field.class);
                Class cls2 = Long.TYPE;
                cls.getMethod("getLong", Object.class, cls2);
                if (h0.g() != null) {
                    try {
                        Class<?> cls3 = this.f2972a.getClass();
                        cls3.getMethod("getByte", cls2);
                        cls3.getMethod("putByte", cls2, Byte.TYPE);
                        cls3.getMethod("getInt", cls2);
                        cls3.getMethod("putInt", cls2, Integer.TYPE);
                        cls3.getMethod("getLong", cls2);
                        cls3.getMethod("putLong", cls2, cls2);
                        cls3.getMethod("copyMemory", cls2, cls2, cls2);
                        cls3.getMethod("copyMemory", Object.class, cls2, Object.class, cls2, cls2);
                        return true;
                    } catch (Throwable th) {
                        h0.a(th);
                        return false;
                    }
                }
            } catch (Throwable th2) {
                h0.a(th2);
            }
        }
        return false;
    }
}
