package l;

import android.os.Handler;
import android.os.Looper;

/* JADX INFO: renamed from: l.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0519c {
    public static Handler a(Looper looper) {
        return Handler.createAsync(looper);
    }
}
