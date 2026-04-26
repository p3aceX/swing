package l1;

import com.google.crypto.tink.shaded.protobuf.S;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final r f5611a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f5612b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f5613c;

    public j(Class cls, int i4, int i5) {
        this(r.a(cls), i4, i5);
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof j)) {
            return false;
        }
        j jVar = (j) obj;
        return this.f5611a.equals(jVar.f5611a) && this.f5612b == jVar.f5612b && this.f5613c == jVar.f5613c;
    }

    public final int hashCode() {
        return ((((this.f5611a.hashCode() ^ 1000003) * 1000003) ^ this.f5612b) * 1000003) ^ this.f5613c;
    }

    public final String toString() {
        String str;
        StringBuilder sb = new StringBuilder("Dependency{anInterface=");
        sb.append(this.f5611a);
        sb.append(", type=");
        int i4 = this.f5612b;
        sb.append(i4 == 1 ? "required" : i4 == 0 ? "optional" : "set");
        sb.append(", injection=");
        int i5 = this.f5613c;
        if (i5 == 0) {
            str = "direct";
        } else if (i5 == 1) {
            str = "provider";
        } else {
            if (i5 != 2) {
                throw new AssertionError(S.d(i5, "Unsupported injection: "));
            }
            str = "deferred";
        }
        return S.h(sb, str, "}");
    }

    public j(r rVar, int i4, int i5) {
        this.f5611a = rVar;
        this.f5612b = i4;
        this.f5613c = i5;
    }
}
