package A;

import android.view.ViewConfiguration;

/* JADX INFO: loaded from: classes.dex */
public abstract class F {
    public static int a(ViewConfiguration viewConfiguration, int i4, int i5, int i6) {
        return viewConfiguration.getScaledMaximumFlingVelocity(i4, i5, i6);
    }

    public static int b(ViewConfiguration viewConfiguration, int i4, int i5, int i6) {
        return viewConfiguration.getScaledMinimumFlingVelocity(i4, i5, i6);
    }
}
