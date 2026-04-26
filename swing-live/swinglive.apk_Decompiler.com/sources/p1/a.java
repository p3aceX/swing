package p1;

import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6177a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f6178b;

    public a(String str, ArrayList arrayList) {
        if (str == null) {
            throw new NullPointerException("Null userAgent");
        }
        this.f6177a = str;
        this.f6178b = arrayList;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof a)) {
            return false;
        }
        a aVar = (a) obj;
        return this.f6177a.equals(aVar.f6177a) && this.f6178b.equals(aVar.f6178b);
    }

    public final int hashCode() {
        return ((this.f6177a.hashCode() ^ 1000003) * 1000003) ^ this.f6178b.hashCode();
    }

    public final String toString() {
        return "HeartBeatResult{userAgent=" + this.f6177a + ", usedDates=" + this.f6178b + "}";
    }
}
