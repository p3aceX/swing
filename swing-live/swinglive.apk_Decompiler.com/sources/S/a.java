package S;

import Q3.x0;
import android.os.Handler;
import android.os.Looper;
import java.util.concurrent.atomic.AtomicBoolean;
import y0.C0740d;

/* JADX INFO: loaded from: classes.dex */
public final class a implements Runnable {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static Handler f1716f;
    public final /* synthetic */ C0740d e;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public volatile int f1718b = 1;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AtomicBoolean f1719c = new AtomicBoolean();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final AtomicBoolean f1720d = new AtomicBoolean();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final c f1717a = new c(this, new b(this));

    public a(C0740d c0740d) {
        this.e = c0740d;
    }

    public final void a(Object obj) {
        Handler handler;
        synchronized (a.class) {
            try {
                if (f1716f == null) {
                    f1716f = new Handler(Looper.getMainLooper());
                }
                handler = f1716f;
            } catch (Throwable th) {
                throw th;
            }
        }
        handler.post(new x0(this, obj, 1, false));
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.e.b();
    }
}
