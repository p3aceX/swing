package m1;

import O.RunnableC0093d;
import android.os.StrictMode;
import java.util.Locale;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicLong;

/* JADX INFO: renamed from: m1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ThreadFactoryC0546a implements ThreadFactory {
    public static final ThreadFactory e = Executors.defaultThreadFactory();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicLong f5763a = new AtomicLong();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5764b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f5765c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final StrictMode.ThreadPolicy f5766d;

    public ThreadFactoryC0546a(String str, int i4, StrictMode.ThreadPolicy threadPolicy) {
        this.f5764b = str;
        this.f5765c = i4;
        this.f5766d = threadPolicy;
    }

    @Override // java.util.concurrent.ThreadFactory
    public final Thread newThread(Runnable runnable) {
        Thread threadNewThread = e.newThread(new RunnableC0093d(10, this, runnable));
        Locale locale = Locale.ROOT;
        threadNewThread.setName(this.f5764b + " Thread #" + this.f5763a.getAndIncrement());
        return threadNewThread;
    }
}
