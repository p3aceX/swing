package Q0;

/* JADX INFO: loaded from: classes.dex */
public final class f implements h {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Object f1530c = new Object();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public volatile g f1531a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public volatile Object f1532b;

    /* JADX WARN: Multi-variable type inference failed */
    public static f b(g gVar) {
        if (gVar instanceof f) {
            return (f) gVar;
        }
        f fVar = new f();
        fVar.f1532b = f1530c;
        fVar.f1531a = gVar;
        return fVar;
    }

    @Override // Q0.h
    public final Object a() {
        Object objA;
        Object obj = this.f1532b;
        Object obj2 = f1530c;
        if (obj != obj2) {
            return obj;
        }
        synchronized (this) {
            try {
                objA = this.f1532b;
                if (objA == obj2) {
                    objA = this.f1531a.a();
                    Object obj3 = this.f1532b;
                    if (obj3 != obj2 && obj3 != objA) {
                        throw new IllegalStateException("Scoped provider was invoked recursively returning different results: " + obj3 + " & " + objA + ". This is likely due to a circular dependency.");
                    }
                    this.f1532b = objA;
                    this.f1531a = null;
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return objA;
    }
}
