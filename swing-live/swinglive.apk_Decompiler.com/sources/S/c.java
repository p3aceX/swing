package S;

import android.util.Log;
import java.util.concurrent.CancellationException;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

/* JADX INFO: loaded from: classes.dex */
public final class c extends FutureTask {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ a f1722a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(a aVar, b bVar) {
        super(bVar);
        this.f1722a = aVar;
    }

    @Override // java.util.concurrent.FutureTask
    public final void done() {
        a aVar = this.f1722a;
        try {
            Object obj = get();
            if (aVar.f1720d.get()) {
                return;
            }
            aVar.a(obj);
        } catch (InterruptedException e) {
            Log.w("AsyncTask", e);
        } catch (CancellationException unused) {
            if (aVar.f1720d.get()) {
                return;
            }
            aVar.a(null);
        } catch (ExecutionException e4) {
            throw new RuntimeException("An error occurred while executing doInBackground()", e4.getCause());
        } catch (Throwable th) {
            throw new RuntimeException("An error occurred while executing doInBackground()", th);
        }
    }
}
