package q;

import android.app.PendingIntent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import androidx.core.graphics.drawable.IconCompat;
import com.swing.live.R;
import java.lang.reflect.InvocationTargetException;

/* JADX INFO: loaded from: classes.dex */
public final class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Bundle f6217a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public IconCompat f6218b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f6219c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f6220d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final CharSequence f6221f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final PendingIntent f6222g;

    public l(String str, PendingIntent pendingIntent) {
        IconCompat iconCompatB = IconCompat.b(R.drawable.common_full_open_on_phone);
        Bundle bundle = new Bundle();
        this.f6220d = true;
        this.f6218b = iconCompatB;
        int iIntValue = iconCompatB.f2858a;
        if (iIntValue == -1) {
            int i4 = Build.VERSION.SDK_INT;
            Object obj = iconCompatB.f2859b;
            if (i4 >= 28) {
                iIntValue = u.d.c(obj);
            } else {
                try {
                    iIntValue = ((Integer) obj.getClass().getMethod("getType", new Class[0]).invoke(obj, new Object[0])).intValue();
                } catch (IllegalAccessException e) {
                    Log.e("IconCompat", "Unable to get icon type " + obj, e);
                    iIntValue = -1;
                } catch (NoSuchMethodException e4) {
                    Log.e("IconCompat", "Unable to get icon type " + obj, e4);
                    iIntValue = -1;
                } catch (InvocationTargetException e5) {
                    Log.e("IconCompat", "Unable to get icon type " + obj, e5);
                    iIntValue = -1;
                }
            }
        }
        if (iIntValue == 2) {
            this.e = iconCompatB.c();
        }
        this.f6221f = m.b(str);
        this.f6222g = pendingIntent;
        this.f6217a = bundle;
        this.f6219c = true;
        this.f6220d = true;
    }
}
