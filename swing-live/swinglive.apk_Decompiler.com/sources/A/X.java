package A;

import android.os.Build;
import android.view.View;
import android.view.WindowInsets;
import java.lang.reflect.Field;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class X {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final V f33a;

    static {
        if (Build.VERSION.SDK_INT >= 30) {
            int i4 = U.f30q;
        } else {
            int i5 = V.f31b;
        }
    }

    public X(WindowInsets windowInsets) {
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 30) {
            this.f33a = new U(this, windowInsets);
            return;
        }
        if (i4 >= 29) {
            this.f33a = new S(this, windowInsets);
        } else if (i4 >= 28) {
            this.f33a = new Q(this, windowInsets);
        } else {
            this.f33a = new P(this, windowInsets);
        }
    }

    public static X a(WindowInsets windowInsets, View view) {
        windowInsets.getClass();
        X x4 = new X(windowInsets);
        if (view != null && view.isAttachedToWindow()) {
            Field field = C.f4a;
            X xA = AbstractC0020u.a(view);
            V v = x4.f33a;
            v.o(xA);
            v.d(view.getRootView());
        }
        return x4;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof X)) {
            return false;
        }
        return Objects.equals(this.f33a, ((X) obj).f33a);
    }

    public final int hashCode() {
        V v = this.f33a;
        if (v == null) {
            return 0;
        }
        return v.hashCode();
    }

    public X() {
        this.f33a = new V(this);
    }
}
