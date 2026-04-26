package w;

import android.content.Context;
import android.os.UserManager;

/* JADX INFO: loaded from: classes.dex */
public abstract class g {
    public static boolean a(Context context) {
        return ((UserManager) context.getSystemService(UserManager.class)).isUserUnlocked();
    }
}
