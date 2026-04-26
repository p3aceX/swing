package R3;

import J3.i;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.view.Choreographer;
import e1.AbstractC0367g;
import java.lang.reflect.InvocationTargetException;

/* JADX INFO: loaded from: classes.dex */
public abstract class e {
    private static volatile Choreographer choreographer;

    static {
        Object objH;
        try {
            objH = new d(a(Looper.getMainLooper()), false);
        } catch (Throwable th) {
            objH = AbstractC0367g.h(th);
        }
        if (objH instanceof w3.d) {
            objH = null;
        }
    }

    public static final Handler a(Looper looper) throws IllegalAccessException, InvocationTargetException {
        if (Build.VERSION.SDK_INT >= 28) {
            Object objInvoke = Handler.class.getDeclaredMethod("createAsync", Looper.class).invoke(null, looper);
            i.c(objInvoke, "null cannot be cast to non-null type android.os.Handler");
            return (Handler) objInvoke;
        }
        try {
            return (Handler) Handler.class.getDeclaredConstructor(Looper.class, Handler.Callback.class, Boolean.TYPE).newInstance(looper, null, Boolean.TRUE);
        } catch (NoSuchMethodException unused) {
            return new Handler(looper);
        }
    }
}
