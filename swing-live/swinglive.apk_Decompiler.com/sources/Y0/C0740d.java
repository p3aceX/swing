package y0;

import android.os.AsyncTask;
import android.util.Log;
import com.google.android.gms.auth.api.signin.internal.SignInHubActivity;
import com.google.android.gms.common.api.o;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.Executor;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

/* JADX INFO: renamed from: y0.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0740d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public R.a f6813a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f6814b = false;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f6815c = false;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f6816d = true;
    public boolean e = false;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Executor f6817f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public volatile S.a f6818g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public volatile S.a f6819h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final Semaphore f6820i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final Set f6821j;

    public C0740d(SignInHubActivity signInHubActivity, Set set) {
        signInHubActivity.getApplicationContext();
        this.f6820i = new Semaphore(0);
        this.f6821j = set;
    }

    public final void a() {
        if (this.f6818g != null) {
            boolean z4 = this.f6814b;
            if (!z4) {
                if (z4) {
                    c();
                } else {
                    this.e = true;
                }
            }
            if (this.f6819h != null) {
                this.f6818g.getClass();
                this.f6818g = null;
                return;
            }
            this.f6818g.getClass();
            S.a aVar = this.f6818g;
            aVar.f1719c.set(true);
            if (aVar.f1717a.cancel(false)) {
                this.f6819h = this.f6818g;
            }
            this.f6818g = null;
        }
    }

    public final void b() {
        if (this.f6819h != null || this.f6818g == null) {
            return;
        }
        this.f6818g.getClass();
        if (this.f6817f == null) {
            this.f6817f = AsyncTask.THREAD_POOL_EXECUTOR;
        }
        S.a aVar = this.f6818g;
        Executor executor = this.f6817f;
        if (aVar.f1718b == 1) {
            aVar.f1718b = 2;
            executor.execute(aVar.f1717a);
            return;
        }
        int iB = K.j.b(aVar.f1718b);
        if (iB == 1) {
            throw new IllegalStateException("Cannot execute task: the task is already running.");
        }
        if (iB == 2) {
            throw new IllegalStateException("Cannot execute task: the task has already been executed (a task can be executed only once)");
        }
        throw new IllegalStateException("We should never reach this state");
    }

    public final void c() {
        a();
        this.f6818g = new S.a(this);
        b();
    }

    public final void d() {
        Iterator it = this.f6821j.iterator();
        if (it.hasNext()) {
            ((o) it.next()).getClass();
            throw new UnsupportedOperationException();
        }
        try {
            this.f6820i.tryAcquire(0, 5L, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Log.i("GACSignInLoader", "Unexpected InterruptedException", e);
            Thread.currentThread().interrupt();
        }
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder(64);
        Class<?> cls = getClass();
        sb.append(cls.getSimpleName());
        sb.append("{");
        sb.append(Integer.toHexString(System.identityHashCode(cls)));
        sb.append(" id=0}");
        return sb.toString();
    }
}
