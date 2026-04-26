package F2;

import io.flutter.embedding.engine.FlutterJNI;
import java.nio.ByteBuffer;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: loaded from: classes.dex */
public final class g implements O2.e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FlutterJNI f458a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f459b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AtomicBoolean f460c = new AtomicBoolean(false);

    public g(FlutterJNI flutterJNI, int i4) {
        this.f458a = flutterJNI;
        this.f459b = i4;
    }

    @Override // O2.e
    public final void a(ByteBuffer byteBuffer) {
        if (this.f460c.getAndSet(true)) {
            throw new IllegalStateException("Reply already submitted");
        }
        int i4 = this.f459b;
        FlutterJNI flutterJNI = this.f458a;
        if (byteBuffer == null) {
            flutterJNI.invokePlatformMessageEmptyResponseCallback(i4);
        } else {
            flutterJNI.invokePlatformMessageResponseCallback(i4, byteBuffer, byteBuffer.position());
        }
    }
}
