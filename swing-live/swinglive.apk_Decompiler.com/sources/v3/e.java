package V3;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.ServiceConfigurationError;

/* JADX INFO: loaded from: classes.dex */
public abstract class e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final List f2221a;

    static {
        try {
            Iterator it = Arrays.asList(new R3.b()).iterator();
            J3.i.e(it, "<this>");
            f2221a = O3.e.o0(new O3.a(new O3.f(it, 1)));
        } catch (Throwable th) {
            throw new ServiceConfigurationError(th.getMessage(), th);
        }
    }
}
