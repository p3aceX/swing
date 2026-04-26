package k;

import android.content.Context;
import android.content.ContextWrapper;

/* JADX INFO: loaded from: classes.dex */
public abstract class i0 extends ContextWrapper {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Object f5397a = null;

    public static void a(Context context) {
        if (context.getResources() instanceof j0) {
            return;
        }
        context.getResources();
        int i4 = t0.f5460a;
    }
}
