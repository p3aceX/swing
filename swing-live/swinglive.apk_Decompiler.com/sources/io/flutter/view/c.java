package io.flutter.view;

import android.view.accessibility.AccessibilityNodeInfo;

/* JADX INFO: loaded from: classes.dex */
public abstract /* synthetic */ class c {
    public static /* synthetic */ AccessibilityNodeInfo.CollectionInfo d(int i4) {
        return new AccessibilityNodeInfo.CollectionInfo(1, i4, false);
    }

    public static /* synthetic */ AccessibilityNodeInfo.CollectionItemInfo e(int i4, boolean z4) {
        return new AccessibilityNodeInfo.CollectionItemInfo(i4, 1, 0, 1, z4);
    }

    public static /* synthetic */ AccessibilityNodeInfo.CollectionItemInfo h(int i4, boolean z4) {
        return new AccessibilityNodeInfo.CollectionItemInfo(0, 1, i4, 1, z4);
    }
}
