package androidx.datastore.preferences.protobuf;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.u, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0209u extends AbstractC0190a {
    private static final int MEMOIZED_SERIALIZED_SIZE_MASK = Integer.MAX_VALUE;
    private static final int MUTABLE_FLAG_MASK = Integer.MIN_VALUE;
    static final int UNINITIALIZED_HASH_CODE = 0;
    static final int UNINITIALIZED_SERIALIZED_SIZE = Integer.MAX_VALUE;
    private static Map<Object, AbstractC0209u> defaultInstanceMap = new ConcurrentHashMap();
    private int memoizedSerializedSize;
    protected b0 unknownFields;

    public AbstractC0209u() {
        this.memoizedHashCode = 0;
        this.memoizedSerializedSize = -1;
        this.unknownFields = b0.f2954f;
    }

    public static AbstractC0209u d(Class cls) {
        AbstractC0209u abstractC0209u = defaultInstanceMap.get(cls);
        if (abstractC0209u == null) {
            try {
                Class.forName(cls.getName(), true, cls.getClassLoader());
                abstractC0209u = defaultInstanceMap.get(cls);
            } catch (ClassNotFoundException e) {
                throw new IllegalStateException("Class initialization cannot fail.", e);
            }
        }
        if (abstractC0209u != null) {
            return abstractC0209u;
        }
        AbstractC0209u abstractC0209u2 = (AbstractC0209u) ((AbstractC0209u) h0.d(cls)).c(6);
        if (abstractC0209u2 == null) {
            throw new IllegalStateException();
        }
        defaultInstanceMap.put(cls, abstractC0209u2);
        return abstractC0209u2;
    }

    public static Object e(Method method, AbstractC0190a abstractC0190a, Object... objArr) {
        try {
            return method.invoke(abstractC0190a, objArr);
        } catch (IllegalAccessException e) {
            throw new RuntimeException("Couldn't use Java reflection to implement protocol message reflection.", e);
        } catch (InvocationTargetException e4) {
            Throwable cause = e4.getCause();
            if (cause instanceof RuntimeException) {
                throw ((RuntimeException) cause);
            }
            if (cause instanceof Error) {
                throw ((Error) cause);
            }
            throw new RuntimeException("Unexpected exception thrown by generated accessor method.", cause);
        }
    }

    public static final boolean f(AbstractC0209u abstractC0209u, boolean z4) {
        byte bByteValue = ((Byte) abstractC0209u.c(1)).byteValue();
        if (bByteValue == 1) {
            return true;
        }
        if (bByteValue == 0) {
            return false;
        }
        Q q4 = Q.f2927c;
        q4.getClass();
        boolean zA = q4.a(abstractC0209u.getClass()).a(abstractC0209u);
        if (z4) {
            abstractC0209u.c(2);
        }
        return zA;
    }

    public static void j(Class cls, AbstractC0209u abstractC0209u) {
        abstractC0209u.h();
        defaultInstanceMap.put(cls, abstractC0209u);
    }

    @Override // androidx.datastore.preferences.protobuf.AbstractC0190a
    public final int a(U u4) {
        int i4;
        int i5;
        if (g()) {
            if (u4 == null) {
                Q q4 = Q.f2927c;
                q4.getClass();
                i5 = q4.a(getClass()).i(this);
            } else {
                i5 = u4.i(this);
            }
            if (i5 >= 0) {
                return i5;
            }
            throw new IllegalStateException(com.google.crypto.tink.shaded.protobuf.S.d(i5, "serialized size must be non-negative, was "));
        }
        int i6 = this.memoizedSerializedSize;
        if ((i6 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER) != Integer.MAX_VALUE) {
            return i6 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
        }
        if (u4 == null) {
            Q q5 = Q.f2927c;
            q5.getClass();
            i4 = q5.a(getClass()).i(this);
        } else {
            i4 = u4.i(this);
        }
        k(i4);
        return i4;
    }

    @Override // androidx.datastore.preferences.protobuf.AbstractC0190a
    public final void b(C0200k c0200k) {
        Q q4 = Q.f2927c;
        q4.getClass();
        U uA = q4.a(getClass());
        D d5 = c0200k.f2999i;
        if (d5 == null) {
            d5 = new D(c0200k);
        }
        uA.g(this, d5);
    }

    public abstract Object c(int i4);

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        Q q4 = Q.f2927c;
        q4.getClass();
        return q4.a(getClass()).e(this, (AbstractC0209u) obj);
    }

    public final boolean g() {
        return (this.memoizedSerializedSize & MUTABLE_FLAG_MASK) != 0;
    }

    public final void h() {
        this.memoizedSerializedSize &= com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
    }

    public final int hashCode() {
        if (g()) {
            Q q4 = Q.f2927c;
            q4.getClass();
            return q4.a(getClass()).h(this);
        }
        if (this.memoizedHashCode == 0) {
            Q q5 = Q.f2927c;
            q5.getClass();
            this.memoizedHashCode = q5.a(getClass()).h(this);
        }
        return this.memoizedHashCode;
    }

    public final AbstractC0209u i() {
        return (AbstractC0209u) c(4);
    }

    public final void k(int i4) {
        if (i4 < 0) {
            throw new IllegalStateException(com.google.crypto.tink.shaded.protobuf.S.d(i4, "serialized size must be non-negative, was "));
        }
        this.memoizedSerializedSize = (i4 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER) | (this.memoizedSerializedSize & MUTABLE_FLAG_MASK);
    }

    public final String toString() {
        String string = super.toString();
        char[] cArr = K.f2907a;
        StringBuilder sb = new StringBuilder();
        sb.append("# ");
        sb.append(string);
        K.c(this, sb, 0);
        return sb.toString();
    }
}
