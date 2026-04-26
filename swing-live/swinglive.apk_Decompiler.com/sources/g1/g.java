package g1;

import Q3.C0120b0;
import R0.k;
import h1.InterfaceC0411a;
import java.util.concurrent.Executor;
import l1.r;

/* JADX INFO: loaded from: classes.dex */
public final class g implements l1.d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final g f4314b = new g(0);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final g f4315c = new g(1);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final g f4316d = new g(2);
    public static final g e = new g(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4317a;

    public /* synthetic */ g(int i4) {
        this.f4317a = i4;
    }

    @Override // l1.d
    public final Object e(k kVar) {
        switch (this.f4317a) {
            case 0:
                Object objB = kVar.b(new r(InterfaceC0411a.class, Executor.class));
                J3.i.d(objB, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB);
            case 1:
                Object objB2 = kVar.b(new r(h1.c.class, Executor.class));
                J3.i.d(objB2, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB2);
            case 2:
                Object objB3 = kVar.b(new r(h1.b.class, Executor.class));
                J3.i.d(objB3, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB3);
            default:
                Object objB4 = kVar.b(new r(h1.d.class, Executor.class));
                J3.i.d(objB4, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB4);
        }
    }
}
