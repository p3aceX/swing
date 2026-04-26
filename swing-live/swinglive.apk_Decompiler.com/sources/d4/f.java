package d4;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.LinkedBlockingQueue;

/* JADX INFO: loaded from: classes.dex */
public final class f implements b4.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public volatile boolean f3968a = false;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ConcurrentHashMap f3969b = new ConcurrentHashMap();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final LinkedBlockingQueue f3970c = new LinkedBlockingQueue();

    @Override // b4.a
    public final synchronized b4.b c() {
        e eVar;
        eVar = (e) this.f3969b.get("io.ktor.util.random");
        if (eVar == null) {
            eVar = new e(this.f3970c, this.f3968a);
            this.f3969b.put("io.ktor.util.random", eVar);
        }
        return eVar;
    }
}
