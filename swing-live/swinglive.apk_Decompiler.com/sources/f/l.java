package F;

import android.widget.PopupWindow;

/* JADX INFO: loaded from: classes.dex */
public abstract class l {
    public static boolean a(PopupWindow popupWindow) {
        return popupWindow.getOverlapAnchor();
    }

    public static int b(PopupWindow popupWindow) {
        return popupWindow.getWindowLayoutType();
    }

    public static void c(PopupWindow popupWindow, boolean z4) {
        popupWindow.setOverlapAnchor(z4);
    }

    public static void d(PopupWindow popupWindow, int i4) {
        popupWindow.setWindowLayoutType(i4);
    }
}
