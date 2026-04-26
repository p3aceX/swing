package K;

import androidx.datastore.preferences.protobuf.AbstractC0191b;
import androidx.datastore.preferences.protobuf.AbstractC0207s;
import androidx.datastore.preferences.protobuf.AbstractC0209u;
import androidx.datastore.preferences.protobuf.AbstractC0211w;
import androidx.datastore.preferences.protobuf.C0208t;
import androidx.datastore.preferences.protobuf.InterfaceC0210v;
import androidx.datastore.preferences.protobuf.P;
import androidx.datastore.preferences.protobuf.S;
import androidx.datastore.preferences.protobuf.T;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.RandomAccess;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public final class h extends AbstractC0209u {
    private static final h DEFAULT_INSTANCE;
    private static volatile P PARSER = null;
    public static final int STRINGS_FIELD_NUMBER = 1;
    private InterfaceC0210v strings_ = S.f2930d;

    static {
        h hVar = new h();
        DEFAULT_INSTANCE = hVar;
        AbstractC0209u.j(h.class, hVar);
    }

    public static void l(h hVar, Set set) {
        InterfaceC0210v interfaceC0210v = hVar.strings_;
        if (!((AbstractC0191b) interfaceC0210v).f2953a) {
            S s4 = (S) interfaceC0210v;
            int i4 = s4.f2932c;
            hVar.strings_ = s4.h(i4 == 0 ? 10 : i4 * 2);
        }
        RandomAccess randomAccess = hVar.strings_;
        Charset charset = AbstractC0211w.f3035a;
        set.getClass();
        if (randomAccess instanceof ArrayList) {
            ((ArrayList) randomAccess).ensureCapacity(set.size() + ((S) randomAccess).f2932c);
        }
        S s5 = (S) randomAccess;
        int i5 = s5.f2932c;
        for (Object obj : set) {
            if (obj == null) {
                String str = "Element at index " + (s5.f2932c - i5) + " is null.";
                for (int i6 = s5.f2932c - 1; i6 >= i5; i6--) {
                    s5.remove(i6);
                }
                throw new NullPointerException(str);
            }
            s5.add(obj);
        }
    }

    public static h m() {
        return DEFAULT_INSTANCE;
    }

    public static g o() {
        return (g) ((AbstractC0207s) DEFAULT_INSTANCE.c(5));
    }

    @Override // androidx.datastore.preferences.protobuf.AbstractC0209u
    public final Object c(int i4) {
        P c0208t;
        switch (j.b(i4)) {
            case 0:
                return (byte) 1;
            case 1:
                return null;
            case 2:
                return new T(DEFAULT_INSTANCE, "\u0001\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0001\u0000\u0001\u001a", new Object[]{"strings_"});
            case 3:
                return new h();
            case 4:
                return new g(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                P p4 = PARSER;
                if (p4 != null) {
                    return p4;
                }
                synchronized (h.class) {
                    try {
                        c0208t = PARSER;
                        if (c0208t == null) {
                            c0208t = new C0208t();
                            PARSER = c0208t;
                        }
                    } catch (Throwable th) {
                        throw th;
                    }
                    break;
                }
                return c0208t;
            default:
                throw new UnsupportedOperationException();
        }
    }

    public final InterfaceC0210v n() {
        return this.strings_;
    }
}
