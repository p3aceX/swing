package com.google.crypto.tink.shaded.protobuf;

import java.lang.reflect.Field;
import sun.misc.Unsafe;

/* JADX INFO: loaded from: classes.dex */
public final class m0 extends n0 {
    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final boolean c(Object obj, long j4) {
        return this.f3820a.getBoolean(obj, j4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final byte d(Object obj, long j4) {
        return this.f3820a.getByte(obj, j4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final double e(Object obj, long j4) {
        return this.f3820a.getDouble(obj, j4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final float f(Object obj, long j4) {
        return this.f3820a.getFloat(obj, j4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void k(Object obj, long j4, boolean z4) {
        this.f3820a.putBoolean(obj, j4, z4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void l(Object obj, long j4, byte b5) {
        this.f3820a.putByte(obj, j4, b5);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void m(Object obj, long j4, double d5) {
        this.f3820a.putDouble(obj, j4, d5);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final void n(Object obj, long j4, float f4) {
        this.f3820a.putFloat(obj, j4, f4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final boolean r() {
        if (!super.r()) {
            return false;
        }
        try {
            Class<?> cls = this.f3820a.getClass();
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
            o0.a(th);
            return false;
        }
    }

    @Override // com.google.crypto.tink.shaded.protobuf.n0
    public final boolean s() {
        Unsafe unsafe = this.f3820a;
        if (unsafe != null) {
            try {
                Class<?> cls = unsafe.getClass();
                cls.getMethod("objectFieldOffset", Field.class);
                Class cls2 = Long.TYPE;
                cls.getMethod("getLong", Object.class, cls2);
                if (o0.e() != null) {
                    try {
                        Class<?> cls3 = this.f3820a.getClass();
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
                        o0.a(th);
                        return false;
                    }
                }
            } catch (Throwable th2) {
                o0.a(th2);
            }
        }
        return false;
    }
}
