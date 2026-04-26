package A;

import android.view.DisplayCutout;
import java.util.Objects;

/* JADX INFO: renamed from: A.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0007g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final DisplayCutout f49a;

    public C0007g(DisplayCutout displayCutout) {
        this.f49a = displayCutout;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || C0007g.class != obj.getClass()) {
            return false;
        }
        return Objects.equals(this.f49a, ((C0007g) obj).f49a);
    }

    public final int hashCode() {
        return this.f49a.hashCode();
    }

    public final String toString() {
        return "DisplayCutoutCompat{" + this.f49a + "}";
    }
}
