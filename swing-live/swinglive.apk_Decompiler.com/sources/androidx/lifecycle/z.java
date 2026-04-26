package androidx.lifecycle;

import android.app.Activity;
import android.app.FragmentManager;
import android.os.Build;
import androidx.lifecycle.B;

/* JADX INFO: loaded from: classes.dex */
public abstract class z {
    /* JADX WARN: Multi-variable type inference failed */
    public static void a(Activity activity, EnumC0221g enumC0221g) {
        p pVarI;
        J3.i.e(enumC0221g, "event");
        if (!(activity instanceof n) || (pVarI = ((n) activity).i()) == null) {
            return;
        }
        pVarI.e(enumC0221g);
    }

    public static void b(Activity activity) {
        if (Build.VERSION.SDK_INT >= 29) {
            B.a.Companion.getClass();
            activity.registerActivityLifecycleCallbacks(new B.a());
        }
        FragmentManager fragmentManager = activity.getFragmentManager();
        if (fragmentManager.findFragmentByTag("androidx.lifecycle.LifecycleDispatcher.report_fragment_tag") == null) {
            fragmentManager.beginTransaction().add(new B(), "androidx.lifecycle.LifecycleDispatcher.report_fragment_tag").commit();
            fragmentManager.executePendingTransactions();
        }
    }
}
