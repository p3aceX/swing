package Y3;

import Q3.C0139l;
import Q3.C0141m;
import Q3.L;
import V3.s;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.atomic.AtomicIntegerFieldUpdater;
import java.util.concurrent.atomic.AtomicLongFieldUpdater;
import java.util.concurrent.atomic.AtomicReferenceArray;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public class h {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2533b = AtomicReferenceFieldUpdater.newUpdater(h.class, Object.class, "head$volatile");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ AtomicLongFieldUpdater f2534c = AtomicLongFieldUpdater.newUpdater(h.class, "deqIdx$volatile");

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f2535d = AtomicReferenceFieldUpdater.newUpdater(h.class, Object.class, "tail$volatile");
    public static final /* synthetic */ AtomicLongFieldUpdater e = AtomicLongFieldUpdater.newUpdater(h.class, "enqIdx$volatile");

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ AtomicIntegerFieldUpdater f2536f = AtomicIntegerFieldUpdater.newUpdater(h.class, "_availablePermits$volatile");
    private volatile /* synthetic */ int _availablePermits$volatile;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0139l f2537a;
    private volatile /* synthetic */ long deqIdx$volatile;
    private volatile /* synthetic */ long enqIdx$volatile;
    private volatile /* synthetic */ Object head$volatile;
    private volatile /* synthetic */ Object tail$volatile;

    public h() {
        j jVar = new j(0L, null, 2);
        this.head$volatile = jVar;
        this.tail$volatile = jVar;
        this._availablePermits$volatile = 1;
        this.f2537a = new C0139l(this, 1);
    }

    public final void a(c cVar) throws IllegalAccessException, L, InvocationTargetException {
        Object objB;
        C0141m c0141m;
        while (true) {
            int andDecrement = f2536f.getAndDecrement(this);
            if (andDecrement <= 1) {
                w3.i iVar = w3.i.f6729a;
                C0141m c0141m2 = cVar.f2527a;
                d dVar = cVar.f2528b;
                if (andDecrement > 0) {
                    d.f2529g.set(dVar, null);
                    c0141m2.A(iVar, c0141m2.f1595c, new C0139l(new M1.a(2, dVar, cVar), 0));
                    return;
                }
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f2535d;
                j jVar = (j) atomicReferenceFieldUpdater.get(this);
                long andIncrement = e.getAndIncrement(this);
                f fVar = f.f2531o;
                long j4 = andIncrement / ((long) i.f2542f);
                while (true) {
                    objB = V3.b.b(jVar, j4, fVar);
                    if (!V3.b.e(objB)) {
                        s sVarC = V3.b.c(objB);
                        while (true) {
                            s sVar = (s) atomicReferenceFieldUpdater.get(this);
                            c0141m = c0141m2;
                            if (sVar.f2248c >= sVarC.f2248c) {
                                break;
                            }
                            if (!sVarC.j()) {
                                break;
                            }
                            while (!atomicReferenceFieldUpdater.compareAndSet(this, sVar, sVarC)) {
                                if (atomicReferenceFieldUpdater.get(this) != sVar) {
                                    if (sVarC.f()) {
                                        sVarC.e();
                                    }
                                    c0141m2 = c0141m;
                                }
                            }
                            if (sVar.f()) {
                                sVar.e();
                            }
                        }
                    } else {
                        c0141m = c0141m2;
                        break;
                    }
                    c0141m2 = c0141m;
                }
                j jVar2 = (j) V3.b.c(objB);
                int i4 = (int) (andIncrement % ((long) i.f2542f));
                AtomicReferenceArray atomicReferenceArray = jVar2.e;
                while (!atomicReferenceArray.compareAndSet(i4, null, cVar)) {
                    if (atomicReferenceArray.get(i4) != null) {
                        C0779j c0779j = i.f2539b;
                        C0779j c0779j2 = i.f2540c;
                        while (!atomicReferenceArray.compareAndSet(i4, c0779j, c0779j2)) {
                            C0141m c0141m3 = c0141m;
                            if (atomicReferenceArray.get(i4) != c0779j) {
                                break;
                            } else {
                                c0141m = c0141m3;
                            }
                        }
                        d.f2529g.set(dVar, null);
                        C0141m c0141m4 = c0141m;
                        c0141m4.A(iVar, c0141m4.f1595c, new C0139l(new M1.a(2, dVar, cVar), 0));
                        return;
                    }
                }
                cVar.a(jVar2, i4);
                return;
            }
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:28:0x0076  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void b() {
        /*
            Method dump skipped, instruction units count: 248
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: Y3.h.b():void");
    }
}
