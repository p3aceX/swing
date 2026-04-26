package x;

import android.os.Process;

/* JADX INFO: renamed from: x.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0711h extends Thread {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6747a;

    public C0711h(Runnable runnable) {
        super(runnable, "fonts-androidx");
        this.f6747a = 10;
    }

    @Override // java.lang.Thread, java.lang.Runnable
    public final void run() {
        Process.setThreadPriority(this.f6747a);
        super.run();
    }
}
