package io.flutter.embedding.engine.renderer;

import io.flutter.view.r;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class b implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4499a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ r f4500b;

    public /* synthetic */ b(r rVar, int i4) {
        this.f4499a = i4;
        this.f4500b = rVar;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f4499a) {
            case 0:
                ((FlutterRenderer$ImageReaderSurfaceProducer) this.f4500b).lambda$dequeueImage$0();
                break;
            default:
                ((g) this.f4500b).getClass();
                break;
        }
    }
}
