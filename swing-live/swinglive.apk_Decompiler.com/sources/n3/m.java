package n3;

import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: loaded from: classes.dex */
public final class m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ AtomicReferenceFieldUpdater f5918a = AtomicReferenceFieldUpdater.newUpdater(m.class, Object.class, "curRef");
    private volatile /* synthetic */ Object curRef = new o(8);

    public final boolean a(r rVar) {
        J3.i.e(rVar, "element");
        while (true) {
            o oVar = (o) this.curRef;
            int iA = oVar.a(rVar);
            if (iA == 0) {
                return true;
            }
            if (iA == 1) {
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f5918a;
                o oVarD = oVar.d();
                while (!atomicReferenceFieldUpdater.compareAndSet(this, oVar, oVarD) && atomicReferenceFieldUpdater.get(this) == oVar) {
                }
            } else if (iA == 2) {
                return false;
            }
        }
    }

    public final void b() {
        while (true) {
            o oVar = (o) this.curRef;
            if (oVar.b()) {
                return;
            }
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f5918a;
            o oVarD = oVar.d();
            while (!atomicReferenceFieldUpdater.compareAndSet(this, oVar, oVarD) && atomicReferenceFieldUpdater.get(this) == oVar) {
            }
        }
    }

    public final boolean c() {
        return ((o) this.curRef).c();
    }

    public final Object d() {
        while (true) {
            o oVar = (o) this.curRef;
            Object objE = oVar.e();
            if (objE != o.f5921f) {
                return objE;
            }
            AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = f5918a;
            o oVarD = oVar.d();
            while (!atomicReferenceFieldUpdater.compareAndSet(this, oVar, oVarD) && atomicReferenceFieldUpdater.get(this) == oVar) {
            }
        }
    }
}
