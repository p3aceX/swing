package s;

import android.content.res.Resources;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Resources f6456a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Resources.Theme f6457b;

    public k(Resources resources, Resources.Theme theme) {
        this.f6456a = resources;
        this.f6457b = theme;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && k.class == obj.getClass()) {
            k kVar = (k) obj;
            if (this.f6456a.equals(kVar.f6456a) && Objects.equals(this.f6457b, kVar.f6457b)) {
                return true;
            }
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hash(this.f6456a, this.f6457b);
    }
}
