package io.flutter.embedding.engine;

import android.view.Surface;
import androidx.annotation.Keep;

/* JADX INFO: loaded from: classes.dex */
@Keep
public class FlutterOverlaySurface {
    private final int id;
    private final Surface surface;

    public FlutterOverlaySurface(int i4, Surface surface) {
        this.id = i4;
        this.surface = surface;
    }

    public int getId() {
        return this.id;
    }

    public Surface getSurface() {
        return this.surface;
    }
}
