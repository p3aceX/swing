package q;

import android.app.NotificationManager;
import android.content.Context;
import java.util.HashSet;

/* JADX INFO: loaded from: classes.dex */
public final class w {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final NotificationManager f6239a;

    static {
        new HashSet();
    }

    public w(Context context) {
        this.f6239a = (NotificationManager) context.getSystemService("notification");
    }
}
