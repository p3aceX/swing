package x;

import java.util.concurrent.ThreadFactory;

/* JADX INFO: renamed from: x.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ThreadFactoryC0712i implements ThreadFactory {
    @Override // java.util.concurrent.ThreadFactory
    public final Thread newThread(Runnable runnable) {
        return new C0711h(runnable);
    }
}
