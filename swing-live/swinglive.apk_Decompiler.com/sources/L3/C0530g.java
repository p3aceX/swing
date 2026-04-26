package l3;

import java.util.List;
import x3.AbstractC0729i;

/* JADX INFO: renamed from: l3.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0530g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5682a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final boolean f5683b;

    public C0530g(String str, boolean z4) {
        this.f5682a = str;
        this.f5683b = z4;
    }

    public final List a() {
        return AbstractC0729i.T(this.f5682a, Boolean.valueOf(this.f5683b));
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0530g)) {
            return false;
        }
        if (this == obj) {
            return true;
        }
        return e1.k.n(a(), ((C0530g) obj).a());
    }

    public final int hashCode() {
        return a().hashCode();
    }

    public final String toString() {
        return "SharedPreferencesPigeonOptions(fileName=" + this.f5682a + ", useDataStore=" + this.f5683b + ")";
    }
}
