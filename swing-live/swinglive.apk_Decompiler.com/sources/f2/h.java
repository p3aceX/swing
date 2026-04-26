package F2;

import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: loaded from: classes.dex */
public final class h implements e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ExecutorService f461a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ConcurrentLinkedQueue f462b = new ConcurrentLinkedQueue();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AtomicBoolean f463c = new AtomicBoolean(false);

    public h(ExecutorService executorService) {
        this.f461a = executorService;
    }

    @Override // F2.e
    public final void a(c cVar) {
        this.f462b.add(cVar);
        this.f461a.execute(new F1.a(this, 1));
    }
}
