package l;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.Executors;

/* JADX INFO: renamed from: l.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0520d extends AbstractC0367g {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Object f5568c = new Object();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public volatile Handler f5569d;

    public C0520d() {
        Executors.newFixedThreadPool(4, new ThreadFactoryC0518b());
    }

    public static Handler c0(Looper looper) {
        if (Build.VERSION.SDK_INT >= 28) {
            return AbstractC0519c.a(looper);
        }
        try {
            return (Handler) Handler.class.getDeclaredConstructor(Looper.class, Handler.Callback.class, Boolean.TYPE).newInstance(looper, null, Boolean.TRUE);
        } catch (IllegalAccessException | InstantiationException | NoSuchMethodException unused) {
            return new Handler(looper);
        } catch (InvocationTargetException unused2) {
            return new Handler(looper);
        }
    }
}
