package t1;

import J3.i;
import Q3.C0120b0;
import R0.k;
import h1.InterfaceC0411a;
import h1.b;
import h1.c;
import java.util.concurrent.Executor;
import l1.d;
import l1.r;

/* JADX INFO: loaded from: classes.dex */
public final class a implements d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final a f6558b = new a(0);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final a f6559c = new a(1);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final a f6560d = new a(2);
    public static final a e = new a(3);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6561a;

    public /* synthetic */ a(int i4) {
        this.f6561a = i4;
    }

    @Override // l1.d
    public final Object e(k kVar) {
        switch (this.f6561a) {
            case 0:
                Object objB = kVar.b(new r(InterfaceC0411a.class, Executor.class));
                i.d(objB, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB);
            case 1:
                Object objB2 = kVar.b(new r(c.class, Executor.class));
                i.d(objB2, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB2);
            case 2:
                Object objB3 = kVar.b(new r(b.class, Executor.class));
                i.d(objB3, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB3);
            default:
                Object objB4 = kVar.b(new r(h1.d.class, Executor.class));
                i.d(objB4, "c.get(Qualified.qualifie…a, Executor::class.java))");
                return new C0120b0((Executor) objB4);
        }
    }
}
