package Q0;

import com.google.android.gms.tasks.TaskCompletionSource;

/* JADX INFO: loaded from: classes.dex */
public abstract class w implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private final TaskCompletionSource f1539a;

    public w() {
        this.f1539a = null;
    }

    public void a(Exception exc) {
        TaskCompletionSource taskCompletionSource = this.f1539a;
        if (taskCompletionSource != null) {
            taskCompletionSource.trySetException(exc);
        }
    }

    public abstract void b();

    public final TaskCompletionSource c() {
        return this.f1539a;
    }

    @Override // java.lang.Runnable
    public final void run() {
        try {
            b();
        } catch (Exception e) {
            a(e);
        }
    }

    public w(TaskCompletionSource taskCompletionSource) {
        this.f1539a = taskCompletionSource;
    }
}
