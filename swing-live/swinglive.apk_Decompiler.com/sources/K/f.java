package K;

import androidx.datastore.preferences.protobuf.AbstractC0207s;
import androidx.datastore.preferences.protobuf.AbstractC0209u;
import androidx.datastore.preferences.protobuf.C0198i;
import androidx.datastore.preferences.protobuf.C0199j;
import androidx.datastore.preferences.protobuf.C0202m;
import androidx.datastore.preferences.protobuf.C0208t;
import androidx.datastore.preferences.protobuf.C0213y;
import androidx.datastore.preferences.protobuf.G;
import androidx.datastore.preferences.protobuf.P;
import androidx.datastore.preferences.protobuf.Q;
import androidx.datastore.preferences.protobuf.T;
import androidx.datastore.preferences.protobuf.U;
import androidx.datastore.preferences.protobuf.a0;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class f extends AbstractC0209u {
    private static final f DEFAULT_INSTANCE;
    private static volatile P PARSER = null;
    public static final int PREFERENCES_FIELD_NUMBER = 1;
    private G preferences_ = G.f2903b;

    static {
        f fVar = new f();
        DEFAULT_INSTANCE = fVar;
        AbstractC0209u.j(f.class, fVar);
    }

    public static G l(f fVar) {
        G g4 = fVar.preferences_;
        if (!g4.f2904a) {
            fVar.preferences_ = g4.b();
        }
        return fVar.preferences_;
    }

    public static d n() {
        return (d) ((AbstractC0207s) DEFAULT_INSTANCE.c(5));
    }

    public static f o(FileInputStream fileInputStream) {
        f fVar = DEFAULT_INSTANCE;
        C0198i c0198i = new C0198i(fileInputStream);
        C0202m c0202mA = C0202m.a();
        AbstractC0209u abstractC0209uI = fVar.i();
        try {
            Q q4 = Q.f2927c;
            q4.getClass();
            U uA = q4.a(abstractC0209uI.getClass());
            C0199j c0199j = (C0199j) c0198i.f1873b;
            if (c0199j == null) {
                c0199j = new C0199j(c0198i);
            }
            uA.f(abstractC0209uI, c0199j, c0202mA);
            uA.d(abstractC0209uI);
            if (AbstractC0209u.f(abstractC0209uI, true)) {
                return (f) abstractC0209uI;
            }
            throw new C0213y(new a0().getMessage());
        } catch (a0 e) {
            throw new C0213y(e.getMessage());
        } catch (C0213y e4) {
            if (e4.f3037a) {
                throw new C0213y(e4.getMessage(), e4);
            }
            throw e4;
        } catch (IOException e5) {
            if (e5.getCause() instanceof C0213y) {
                throw ((C0213y) e5.getCause());
            }
            throw new C0213y(e5.getMessage(), e5);
        } catch (RuntimeException e6) {
            if (e6.getCause() instanceof C0213y) {
                throw ((C0213y) e6.getCause());
            }
            throw e6;
        }
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
                return new T(DEFAULT_INSTANCE, "\u0001\u0001\u0000\u0000\u0001\u0001\u0001\u0001\u0000\u0000\u00012", new Object[]{"preferences_", e.f842a});
            case 3:
                return new f();
            case 4:
                return new d(DEFAULT_INSTANCE);
            case 5:
                return DEFAULT_INSTANCE;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                P p4 = PARSER;
                if (p4 != null) {
                    return p4;
                }
                synchronized (f.class) {
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

    public final Map m() {
        return Collections.unmodifiableMap(this.preferences_);
    }
}
