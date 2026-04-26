package J3;

/* JADX INFO: loaded from: classes.dex */
public final class l implements d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Class f827a;

    public l(Class cls) {
        this.f827a = cls;
    }

    @Override // J3.d
    public final Class a() {
        return this.f827a;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof l) {
            return i.a(this.f827a, ((l) obj).f827a);
        }
        return false;
    }

    public final int hashCode() {
        return this.f827a.hashCode();
    }

    public final String toString() {
        return this.f827a.toString() + " (Kotlin reflection is not available)";
    }
}
