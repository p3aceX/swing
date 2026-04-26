package A;

import android.view.VelocityTracker;

/* JADX INFO: renamed from: A.o, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0015o {
    public static float a(VelocityTracker velocityTracker, int i4) {
        return velocityTracker.getAxisVelocity(i4);
    }

    public static float b(VelocityTracker velocityTracker, int i4, int i5) {
        return velocityTracker.getAxisVelocity(i4, i5);
    }

    public static boolean c(VelocityTracker velocityTracker, int i4) {
        return velocityTracker.isAxisSupported(i4);
    }
}
