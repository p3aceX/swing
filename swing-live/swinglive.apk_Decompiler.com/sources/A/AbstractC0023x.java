package A;

import android.view.View;
import com.swing.live.R;
import java.util.Objects;

/* JADX INFO: renamed from: A.x, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0023x {
    public static void a(View view, A a5) {
        n.k kVar = (n.k) view.getTag(R.id.tag_unhandled_key_listeners);
        if (kVar == null) {
            kVar = new n.k();
            view.setTag(R.id.tag_unhandled_key_listeners, kVar);
        }
        Objects.requireNonNull(a5);
        View.OnUnhandledKeyEventListener viewOnUnhandledKeyEventListenerC0022w = new ViewOnUnhandledKeyEventListenerC0022w();
        kVar.put(a5, viewOnUnhandledKeyEventListenerC0022w);
        view.addOnUnhandledKeyEventListener(viewOnUnhandledKeyEventListenerC0022w);
    }

    public static CharSequence b(View view) {
        return view.getAccessibilityPaneTitle();
    }

    public static boolean c(View view) {
        return view.isAccessibilityHeading();
    }

    public static boolean d(View view) {
        return view.isScreenReaderFocusable();
    }

    public static void e(View view, A a5) {
        View.OnUnhandledKeyEventListener onUnhandledKeyEventListener;
        n.k kVar = (n.k) view.getTag(R.id.tag_unhandled_key_listeners);
        if (kVar == null || (onUnhandledKeyEventListener = (View.OnUnhandledKeyEventListener) kVar.getOrDefault(a5, null)) == null) {
            return;
        }
        view.removeOnUnhandledKeyEventListener(onUnhandledKeyEventListener);
    }

    public static <T> T f(View view, int i4) {
        return (T) view.requireViewById(i4);
    }

    public static void g(View view, boolean z4) {
        view.setAccessibilityHeading(z4);
    }

    public static void h(View view, CharSequence charSequence) {
        view.setAccessibilityPaneTitle(charSequence);
    }

    public static void i(View view, C.a aVar) {
        view.setAutofillId(null);
    }

    public static void j(View view, boolean z4) {
        view.setScreenReaderFocusable(z4);
    }
}
