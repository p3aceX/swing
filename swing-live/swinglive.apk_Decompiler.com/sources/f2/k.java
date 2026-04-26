package F2;

import android.os.Build;
import android.os.Handler;
import android.os.Looper;

/* JADX INFO: loaded from: classes.dex */
public final class k implements e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Handler f473a;

    public k() {
        Looper mainLooper = Looper.getMainLooper();
        this.f473a = Build.VERSION.SDK_INT >= 28 ? Handler.createAsync(mainLooper) : new Handler(mainLooper);
    }

    @Override // F2.e
    public final void a(c cVar) {
        this.f473a.post(cVar);
    }
}
