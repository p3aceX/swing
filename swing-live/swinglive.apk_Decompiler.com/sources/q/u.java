package q;

import android.app.Notification;

/* JADX INFO: loaded from: classes.dex */
public abstract class u {
    public static Notification.Action.Builder a(Notification.Action.Builder builder, boolean z4) {
        return builder.setAuthenticationRequired(z4);
    }

    public static Notification.Builder b(Notification.Builder builder, int i4) {
        return builder.setForegroundServiceBehavior(i4);
    }
}
