package T2;

import java.lang.Thread;

/* JADX INFO: renamed from: T2.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0159d implements Thread.UncaughtExceptionHandler {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ C0161f f1935a;

    public C0159d(C0161f c0161f) {
        this.f1935a = c0161f;
    }

    @Override // java.lang.Thread.UncaughtExceptionHandler
    public final void uncaughtException(Thread thread, Throwable th) {
        this.f1935a.f1946h.W("Failed to process frames after camera was flipped.");
    }
}
