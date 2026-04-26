package O3;

import java.util.Iterator;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class a implements c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicReference f1461a;

    public a(f fVar) {
        this.f1461a = new AtomicReference(fVar);
    }

    @Override // O3.c
    public final Iterator iterator() {
        c cVar = (c) this.f1461a.getAndSet(null);
        if (cVar != null) {
            return cVar.iterator();
        }
        throw new IllegalStateException("This sequence can be consumed only once.");
    }
}
