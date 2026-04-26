package w3;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public final class f implements Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public I3.a f6722a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public volatile Object f6723b = h.f6728a;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f6724c = this;

    public f(I3.a aVar) {
        this.f6722a = aVar;
    }

    public final Object a() {
        Object objA;
        Object obj = this.f6723b;
        h hVar = h.f6728a;
        if (obj != hVar) {
            return obj;
        }
        synchronized (this.f6724c) {
            objA = this.f6723b;
            if (objA == hVar) {
                I3.a aVar = this.f6722a;
                J3.i.b(aVar);
                objA = aVar.a();
                this.f6723b = objA;
                this.f6722a = null;
            }
        }
        return objA;
    }

    public final String toString() {
        return this.f6723b != h.f6728a ? String.valueOf(a()) : "Lazy value not initialized yet.";
    }
}
