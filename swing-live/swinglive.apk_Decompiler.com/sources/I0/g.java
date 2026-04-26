package i0;

import J3.s;
import android.content.Context;
import j0.InterfaceC0450a;
import java.math.BigInteger;
import java.util.concurrent.locks.ReentrantLock;

/* JADX INFO: loaded from: classes.dex */
public final class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ g f4474a = new g();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final w3.f f4475b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0420a f4476c;

    static {
        s.a(h.class).b();
        f4475b = new w3.f(f.f4473a);
        f4476c = C0420a.f4456a;
    }

    public static b a(Context context) {
        J3.i.e(context, "context");
        InterfaceC0450a interfaceC0450a = (InterfaceC0450a) f4475b.a();
        if (interfaceC0450a == null) {
            l0.k kVar = l0.k.f5585c;
            if (l0.k.f5585c == null) {
                ReentrantLock reentrantLock = l0.k.f5586d;
                reentrantLock.lock();
                try {
                    if (l0.k.f5585c == null) {
                        l0.i iVar = null;
                        try {
                            f0.h hVarB = l0.h.b();
                            if (hVarB != null) {
                                f0.h hVar = f0.h.f4279f;
                                J3.i.e(hVar, "other");
                                Object objA = hVarB.e.a();
                                J3.i.d(objA, "<get-bigInteger>(...)");
                                Object objA2 = hVar.e.a();
                                J3.i.d(objA2, "<get-bigInteger>(...)");
                                if (((BigInteger) objA).compareTo((BigInteger) objA2) >= 0) {
                                    l0.i iVar2 = new l0.i(context);
                                    if (iVar2.e()) {
                                        iVar = iVar2;
                                    }
                                }
                            }
                        } catch (Throwable unused) {
                        }
                        l0.k.f5585c = new l0.k(iVar);
                    }
                } finally {
                    reentrantLock.unlock();
                }
            }
            interfaceC0450a = l0.k.f5585c;
            J3.i.b(interfaceC0450a);
        }
        int i4 = n.f4486b;
        b bVar = new b(interfaceC0450a);
        f4476c.getClass();
        return bVar;
    }
}
