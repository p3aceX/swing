package A;

import android.util.Log;
import android.view.View;
import java.lang.reflect.Field;

/* JADX INFO: loaded from: classes.dex */
public abstract class I {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Field f7a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Field f8b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Field f9c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final boolean f10d;

    static {
        try {
            Field declaredField = View.class.getDeclaredField("mAttachInfo");
            f7a = declaredField;
            declaredField.setAccessible(true);
            Class<?> cls = Class.forName("android.view.View$AttachInfo");
            Field declaredField2 = cls.getDeclaredField("mStableInsets");
            f8b = declaredField2;
            declaredField2.setAccessible(true);
            Field declaredField3 = cls.getDeclaredField("mContentInsets");
            f9c = declaredField3;
            declaredField3.setAccessible(true);
            f10d = true;
        } catch (ReflectiveOperationException e) {
            Log.w("WindowInsetsCompat", "Failed to get visible insets from AttachInfo " + e.getMessage(), e);
        }
    }
}
