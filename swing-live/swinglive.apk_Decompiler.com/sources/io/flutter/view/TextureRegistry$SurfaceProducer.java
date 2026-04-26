package io.flutter.view;

import android.view.Surface;
import androidx.annotation.Keep;

/* JADX INFO: loaded from: classes.dex */
@Keep
public interface TextureRegistry$SurfaceProducer {
    Surface getForcedNewSurface();

    int getHeight();

    Surface getSurface();

    int getWidth();

    boolean handlesCropAndRotation();

    /* synthetic */ long id();

    /* synthetic */ void release();

    void scheduleFrame();

    void setCallback(s sVar);

    void setSize(int i4, int i5);
}
