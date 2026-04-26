package m;

import java.util.Map;

/* JADX INFO: renamed from: m.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0541c implements Map.Entry {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Object f5751a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f5752b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public C0541c f5753c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0541c f5754d;

    public C0541c(Object obj, Object obj2) {
        this.f5751a = obj;
        this.f5752b = obj2;
    }

    @Override // java.util.Map.Entry
    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0541c)) {
            return false;
        }
        C0541c c0541c = (C0541c) obj;
        return this.f5751a.equals(c0541c.f5751a) && this.f5752b.equals(c0541c.f5752b);
    }

    @Override // java.util.Map.Entry
    public final Object getKey() {
        return this.f5751a;
    }

    @Override // java.util.Map.Entry
    public final Object getValue() {
        return this.f5752b;
    }

    @Override // java.util.Map.Entry
    public final int hashCode() {
        return this.f5751a.hashCode() ^ this.f5752b.hashCode();
    }

    @Override // java.util.Map.Entry
    public final Object setValue(Object obj) {
        throw new UnsupportedOperationException("An entry modification is not supported");
    }

    public final String toString() {
        return this.f5751a + "=" + this.f5752b;
    }
}
