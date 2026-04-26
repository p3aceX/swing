package io.flutter.view;

import android.media.Image;
import androidx.annotation.Keep;

/* JADX INFO: loaded from: classes.dex */
@Keep
public interface TextureRegistry$ImageTextureEntry {
    /* synthetic */ long id();

    void pushImage(Image image);

    /* synthetic */ void release();
}
