package androidx.datastore.preferences.protobuf;

import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public final class X implements Map.Entry, Comparable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Comparable f2945a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f2946b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ W f2947c;

    public X(W w4, Comparable comparable, Object obj) {
        this.f2947c = w4;
        this.f2945a = comparable;
        this.f2946b = obj;
    }

    @Override // java.lang.Comparable
    public final int compareTo(Object obj) {
        return this.f2945a.compareTo(((X) obj).f2945a);
    }

    @Override // java.util.Map.Entry
    public final boolean equals(Object obj) {
        if (obj != this) {
            if (obj instanceof Map.Entry) {
                Map.Entry entry = (Map.Entry) obj;
                Object key = entry.getKey();
                Comparable comparable = this.f2945a;
                if (comparable == null ? key == null : comparable.equals(key)) {
                    Object obj2 = this.f2946b;
                    Object value = entry.getValue();
                    if (obj2 == null ? value == null : obj2.equals(value)) {
                    }
                }
            }
            return false;
        }
        return true;
    }

    @Override // java.util.Map.Entry
    public final Object getKey() {
        return this.f2945a;
    }

    @Override // java.util.Map.Entry
    public final Object getValue() {
        return this.f2946b;
    }

    @Override // java.util.Map.Entry
    public final int hashCode() {
        Comparable comparable = this.f2945a;
        int iHashCode = comparable == null ? 0 : comparable.hashCode();
        Object obj = this.f2946b;
        return (obj != null ? obj.hashCode() : 0) ^ iHashCode;
    }

    @Override // java.util.Map.Entry
    public final Object setValue(Object obj) {
        this.f2947c.b();
        Object obj2 = this.f2946b;
        this.f2946b = obj;
        return obj2;
    }

    public final String toString() {
        return this.f2945a + "=" + this.f2946b;
    }
}
