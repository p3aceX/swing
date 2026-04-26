package i0;

import android.app.ActivityManager;
import android.text.PrecomputedText;
import android.text.TextPaint;
import android.view.DisplayCutout;

/* JADX INFO: loaded from: classes.dex */
public abstract /* synthetic */ class m {
    public static /* synthetic */ ActivityManager.TaskDescription c(int i4, String str) {
        return new ActivityManager.TaskDescription(str, 0, i4);
    }

    public static /* synthetic */ PrecomputedText.Params.Builder g(TextPaint textPaint) {
        return new PrecomputedText.Params.Builder(textPaint);
    }

    public static /* bridge */ /* synthetic */ DisplayCutout j(Object obj) {
        return (DisplayCutout) obj;
    }

    public static /* bridge */ /* synthetic */ boolean p(Object obj) {
        return obj instanceof DisplayCutout;
    }
}
