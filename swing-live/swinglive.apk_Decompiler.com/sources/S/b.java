package S;

import android.os.Binder;
import android.os.Process;
import java.util.concurrent.Callable;

/* JADX INFO: loaded from: classes.dex */
public final class b implements Callable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ a f1721a;

    public b(a aVar) {
        this.f1721a = aVar;
    }

    @Override // java.util.concurrent.Callable
    public final Object call() {
        a aVar = this.f1721a;
        aVar.f1720d.set(true);
        try {
            Process.setThreadPriority(10);
            aVar.e.d();
            Binder.flushPendingCommands();
            return null;
        } finally {
        }
    }
}
