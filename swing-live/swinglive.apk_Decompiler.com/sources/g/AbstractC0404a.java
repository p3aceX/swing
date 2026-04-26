package g;

import android.content.Context;
import android.graphics.drawable.Drawable;
import java.util.WeakHashMap;
import k.P;

/* JADX INFO: renamed from: g.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0404a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Object f4294a = null;

    static {
        new ThreadLocal();
        new WeakHashMap(0);
    }

    public static Drawable a(Context context, int i4) {
        return P.b().c(context, i4);
    }
}
