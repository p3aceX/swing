package w;

import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public final class d {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final d f6679b = new d(new e(c.a(new Locale[0])));

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final e f6680a;

    public d(e eVar) {
        this.f6680a = eVar;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof d) {
            return this.f6680a.equals(((d) obj).f6680a);
        }
        return false;
    }

    public final int hashCode() {
        return this.f6680a.f6681a.hashCode();
    }

    public final String toString() {
        return this.f6680a.f6681a.toString();
    }
}
