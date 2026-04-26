package io.flutter.embedding.engine.renderer;

import io.flutter.embedding.engine.FlutterJNI;

/* JADX INFO: loaded from: classes.dex */
public final class h implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f4513a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final FlutterJNI f4514b;

    public h(long j4, FlutterJNI flutterJNI) {
        this.f4513a = j4;
        this.f4514b = flutterJNI;
    }

    @Override // java.lang.Runnable
    public final void run() {
        FlutterJNI flutterJNI = this.f4514b;
        if (flutterJNI.isAttached()) {
            flutterJNI.unregisterTexture(this.f4513a);
        }
    }
}
