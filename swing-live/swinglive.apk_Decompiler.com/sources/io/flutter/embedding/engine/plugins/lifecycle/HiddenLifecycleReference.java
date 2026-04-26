package io.flutter.embedding.engine.plugins.lifecycle;

import androidx.annotation.Keep;
import androidx.lifecycle.AbstractC0223i;

/* JADX INFO: loaded from: classes.dex */
@Keep
public class HiddenLifecycleReference {
    private final AbstractC0223i lifecycle;

    public HiddenLifecycleReference(AbstractC0223i abstractC0223i) {
        this.lifecycle = abstractC0223i;
    }

    public AbstractC0223i getLifecycle() {
        return this.lifecycle;
    }
}
