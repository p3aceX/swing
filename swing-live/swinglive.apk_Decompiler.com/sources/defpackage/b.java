package defpackage;

import a.AbstractC0184a;
import e1.k;

/* JADX INFO: loaded from: classes.dex */
public final class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Boolean f3203a;

    public b(Boolean bool) {
        this.f3203a = bool;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof b)) {
            return false;
        }
        if (this == obj) {
            return true;
        }
        return AbstractC0184a.A(k.x(this.f3203a), k.x(((b) obj).f3203a));
    }

    public final int hashCode() {
        return k.x(this.f3203a).hashCode();
    }

    public final String toString() {
        return "ToggleMessage(enable=" + this.f3203a + ")";
    }
}
