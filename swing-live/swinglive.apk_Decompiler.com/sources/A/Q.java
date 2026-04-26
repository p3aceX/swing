package A;

import android.view.DisplayCutout;
import android.view.WindowInsets;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public class Q extends P {
    public Q(X x4, WindowInsets windowInsets) {
        super(x4, windowInsets);
    }

    @Override // A.V
    public X a() {
        return X.a(this.f22c.consumeDisplayCutout(), null);
    }

    @Override // A.V
    public C0007g e() {
        DisplayCutout displayCutout = this.f22c.getDisplayCutout();
        if (displayCutout == null) {
            return null;
        }
        return new C0007g(displayCutout);
    }

    @Override // A.O, A.V
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof Q)) {
            return false;
        }
        Q q4 = (Q) obj;
        return Objects.equals(this.f22c, q4.f22c) && Objects.equals(this.f25g, q4.f25g);
    }

    @Override // A.V
    public int hashCode() {
        return this.f22c.hashCode();
    }
}
