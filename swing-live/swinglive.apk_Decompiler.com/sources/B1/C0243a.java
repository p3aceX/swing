package b1;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: renamed from: b1.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0243a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0243a f3269b = new C0243a(Collections.unmodifiableMap(new HashMap()));

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Map f3270a;

    public C0243a(Map map) {
        this.f3270a = map;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof C0243a) {
            return this.f3270a.equals(((C0243a) obj).f3270a);
        }
        return false;
    }

    public final int hashCode() {
        return this.f3270a.hashCode();
    }

    public final String toString() {
        return this.f3270a.toString();
    }
}
