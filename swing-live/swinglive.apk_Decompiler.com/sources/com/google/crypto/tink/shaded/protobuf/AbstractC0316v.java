package com.google.crypto.tink.shaded.protobuf;

import androidx.datastore.preferences.protobuf.C0199j;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/* JADX INFO: renamed from: com.google.crypto.tink.shaded.protobuf.v, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0316v extends AbstractC0296a {
    private static final int MEMOIZED_SERIALIZED_SIZE_MASK = Integer.MAX_VALUE;
    private static final int MUTABLE_FLAG_MASK = Integer.MIN_VALUE;
    static final int UNINITIALIZED_HASH_CODE = 0;
    static final int UNINITIALIZED_SERIALIZED_SIZE = Integer.MAX_VALUE;
    private static Map<Object, AbstractC0316v> defaultInstanceMap = new ConcurrentHashMap();
    private int memoizedSerializedSize;
    protected f0 unknownFields;

    public AbstractC0316v() {
        this.memoizedHashCode = 0;
        this.memoizedSerializedSize = -1;
        this.unknownFields = f0.f3785f;
    }

    public static void g(AbstractC0316v abstractC0316v) throws B {
        if (!m(abstractC0316v, true)) {
            throw new B(new e0().getMessage());
        }
    }

    public static AbstractC0316v j(Class cls) {
        AbstractC0316v abstractC0316v = defaultInstanceMap.get(cls);
        if (abstractC0316v == null) {
            try {
                Class.forName(cls.getName(), true, cls.getClassLoader());
                abstractC0316v = defaultInstanceMap.get(cls);
            } catch (ClassNotFoundException e) {
                throw new IllegalStateException("Class initialization cannot fail.", e);
            }
        }
        if (abstractC0316v != null) {
            return abstractC0316v;
        }
        AbstractC0316v abstractC0316vA = ((AbstractC0316v) o0.b(cls)).a();
        if (abstractC0316vA == null) {
            throw new IllegalStateException();
        }
        defaultInstanceMap.put(cls, abstractC0316vA);
        return abstractC0316vA;
    }

    public static Object l(Method method, AbstractC0296a abstractC0296a, Object... objArr) {
        try {
            return method.invoke(abstractC0296a, objArr);
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

    public static final boolean m(AbstractC0316v abstractC0316v, boolean z4) {
        byte bByteValue = ((Byte) abstractC0316v.i(1)).byteValue();
        if (bByteValue == 1) {
            return true;
        }
        if (bByteValue == 0) {
            return false;
        }
        Z z5 = Z.f3766c;
        z5.getClass();
        boolean zA = z5.a(abstractC0316v.getClass()).a(abstractC0316v);
        if (z4) {
            abstractC0316v.i(2);
        }
        return zA;
    }

    public static AbstractC0316v r(AbstractC0316v abstractC0316v, AbstractC0303h abstractC0303h, C0309n c0309n) throws B {
        C0302g c0302g = (C0302g) abstractC0303h;
        C0304i c0304iH = T0.d.h(c0302g.f3790d, c0302g.k(), c0302g.size(), true);
        AbstractC0316v abstractC0316vS = s(abstractC0316v, c0304iH, c0309n);
        c0304iH.b(0);
        g(abstractC0316vS);
        return abstractC0316vS;
    }

    public static AbstractC0316v s(AbstractC0316v abstractC0316v, T0.d dVar, C0309n c0309n) throws B {
        AbstractC0316v abstractC0316vQ = abstractC0316v.q();
        try {
            Z z4 = Z.f3766c;
            z4.getClass();
            c0 c0VarA = z4.a(abstractC0316vQ.getClass());
            C0199j c0199j = (C0199j) dVar.f1873b;
            if (c0199j == null) {
                c0199j = new C0199j(dVar, (byte) 0);
            }
            c0VarA.j(abstractC0316vQ, c0199j, c0309n);
            c0VarA.d(abstractC0316vQ);
            return abstractC0316vQ;
        } catch (B e) {
            if (e.f3723a) {
                throw new B(e.getMessage(), e);
            }
            throw e;
        } catch (e0 e4) {
            throw new B(e4.getMessage());
        } catch (IOException e5) {
            if (e5.getCause() instanceof B) {
                throw ((B) e5.getCause());
            }
            throw new B(e5.getMessage(), e5);
        } catch (RuntimeException e6) {
            if (e6.getCause() instanceof B) {
                throw ((B) e6.getCause());
            }
            throw e6;
        }
    }

    public static void t(Class cls, AbstractC0316v abstractC0316v) {
        abstractC0316v.o();
        defaultInstanceMap.put(cls, abstractC0316v);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0296a
    public final int b(c0 c0Var) {
        int iE;
        int iE2;
        if (n()) {
            if (c0Var == null) {
                Z z4 = Z.f3766c;
                z4.getClass();
                iE2 = z4.a(getClass()).e(this);
            } else {
                iE2 = c0Var.e(this);
            }
            if (iE2 >= 0) {
                return iE2;
            }
            throw new IllegalStateException(S.d(iE2, "serialized size must be non-negative, was "));
        }
        int i4 = this.memoizedSerializedSize;
        if ((i4 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER) != Integer.MAX_VALUE) {
            return i4 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
        }
        if (c0Var == null) {
            Z z5 = Z.f3766c;
            z5.getClass();
            iE = z5.a(getClass()).e(this);
        } else {
            iE = c0Var.e(this);
        }
        u(iE);
        return iE;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        Z z4 = Z.f3766c;
        z4.getClass();
        return z4.a(getClass()).f(this, (AbstractC0316v) obj);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0296a
    public final void f(C0306k c0306k) {
        Z z4 = Z.f3766c;
        z4.getClass();
        c0 c0VarA = z4.a(getClass());
        K k4 = c0306k.f3812i;
        if (k4 == null) {
            k4 = new K(c0306k);
        }
        c0VarA.h(this, k4);
    }

    public final AbstractC0314t h() {
        return (AbstractC0314t) i(5);
    }

    public final int hashCode() {
        if (n()) {
            Z z4 = Z.f3766c;
            z4.getClass();
            return z4.a(getClass()).i(this);
        }
        if (this.memoizedHashCode == 0) {
            Z z5 = Z.f3766c;
            z5.getClass();
            this.memoizedHashCode = z5.a(getClass()).i(this);
        }
        return this.memoizedHashCode;
    }

    public abstract Object i(int i4);

    @Override // com.google.crypto.tink.shaded.protobuf.P
    /* JADX INFO: renamed from: k, reason: merged with bridge method [inline-methods] */
    public final AbstractC0316v a() {
        return (AbstractC0316v) i(6);
    }

    public final boolean n() {
        return (this.memoizedSerializedSize & MUTABLE_FLAG_MASK) != 0;
    }

    public final void o() {
        this.memoizedSerializedSize &= com.google.android.gms.common.api.f.API_PRIORITY_OTHER;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0296a
    /* JADX INFO: renamed from: p, reason: merged with bridge method [inline-methods] */
    public final AbstractC0314t d() {
        return (AbstractC0314t) i(5);
    }

    public final AbstractC0316v q() {
        return (AbstractC0316v) i(4);
    }

    public final String toString() {
        String string = super.toString();
        char[] cArr = Q.f3745a;
        StringBuilder sb = new StringBuilder();
        sb.append("# ");
        sb.append(string);
        Q.c(this, sb, 0);
        return sb.toString();
    }

    public final void u(int i4) {
        if (i4 < 0) {
            throw new IllegalStateException(S.d(i4, "serialized size must be non-negative, was "));
        }
        this.memoizedSerializedSize = (i4 & com.google.android.gms.common.api.f.API_PRIORITY_OTHER) | (this.memoizedSerializedSize & MUTABLE_FLAG_MASK);
    }

    public final AbstractC0314t v() {
        AbstractC0314t abstractC0314t = (AbstractC0314t) i(5);
        if (!abstractC0314t.f3837a.equals(this)) {
            abstractC0314t.e();
            AbstractC0314t.f(abstractC0314t.f3838b, this);
        }
        return abstractC0314t;
    }
}
