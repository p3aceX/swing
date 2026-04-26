package io.flutter.plugin.platform;

import android.view.Surface;

/* JADX INFO: loaded from: classes.dex */
public interface h {
    long b();

    void d(int i4, int i5);

    int getHeight();

    Surface getSurface();

    int getWidth();

    void release();

    default void scheduleFrame() {
    }
}
