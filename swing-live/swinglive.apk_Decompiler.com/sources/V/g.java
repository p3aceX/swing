package V;

import android.content.Context;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class g implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2162a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Context f2163b;

    public /* synthetic */ g(Context context, int i4) {
        this.f2162a = i4;
        this.f2163b = context;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f2162a) {
            case 0:
                new ThreadPoolExecutor(0, 1, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue()).execute(new g(this.f2163b, 1));
                break;
            default:
                f.s(this.f2163b, new d(), f.f2153a, false);
                break;
        }
    }
}
