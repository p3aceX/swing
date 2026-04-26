package F2;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f440a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f441b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f442c;

    public a(String str, String str2) {
        this.f440a = str;
        this.f441b = null;
        this.f442c = str2;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || a.class != obj.getClass()) {
            return false;
        }
        a aVar = (a) obj;
        if (this.f440a.equals(aVar.f440a)) {
            return this.f442c.equals(aVar.f442c);
        }
        return false;
    }

    public final int hashCode() {
        return this.f442c.hashCode() + (this.f440a.hashCode() * 31);
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("DartEntrypoint( bundle path: ");
        sb.append(this.f440a);
        sb.append(", function: ");
        return S.h(sb, this.f442c, " )");
    }

    public a(String str, String str2, String str3) {
        this.f440a = str;
        this.f441b = str2;
        this.f442c = str3;
    }
}
