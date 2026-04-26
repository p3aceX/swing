package defpackage;

import a.AbstractC0184a;
import e1.k;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Boolean f2627a;

    public a(Boolean bool) {
        this.f2627a = bool;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof a)) {
            return false;
        }
        if (this == obj) {
            return true;
        }
        return AbstractC0184a.A(k.x(this.f2627a), k.x(((a) obj).f2627a));
    }

    public final int hashCode() {
        return k.x(this.f2627a).hashCode();
    }

    public final String toString() {
        return "IsEnabledMessage(enabled=" + this.f2627a + ")";
    }
}
