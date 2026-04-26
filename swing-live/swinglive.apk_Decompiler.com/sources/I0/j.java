package i0;

import java.util.List;
import x3.AbstractC0728h;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f4482a;

    public j(List list) {
        this.f4482a = list;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || !j.class.equals(obj.getClass())) {
            return false;
        }
        return this.f4482a.equals(((j) obj).f4482a);
    }

    public final int hashCode() {
        return this.f4482a.hashCode();
    }

    /* JADX WARN: Type inference failed for: r0v0, types: [java.lang.Iterable, java.lang.Object] */
    public final String toString() {
        return AbstractC0728h.a0(this.f4482a, ", ", "WindowLayoutInfo{ DisplayFeatures[", "] }", null, 56);
    }
}
